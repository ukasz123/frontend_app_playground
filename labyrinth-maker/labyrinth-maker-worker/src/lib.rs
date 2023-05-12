use worker::*;

mod utils;

fn log_request(req: &Request) {
    console_log!(
        "{} - [{}], located at: {:?}, within: {}",
        Date::now().to_string(),
        req.path(),
        req.cf().coordinates().unwrap_or_default(),
        req.cf().region().unwrap_or_else(|| "unknown region".into())
    );
}

#[derive(Debug)]
enum MakerError {
    MissingParam(&'static str),
    InvalidParam(&'static str),
}
impl From<MakerError> for worker::Error {
    fn from(value: MakerError) -> Self {
        match value {
            MakerError::MissingParam(param_name) => {
                worker::Error::RustError(format!("Missing param {param_name}"))
            }
            MakerError::InvalidParam(param_name) => {
                worker::Error::RustError(format!("Invalid value in param {param_name}"))
            }
        }
    }
}

#[event(fetch)]
pub async fn main(req: Request, env: Env, _ctx: worker::Context) -> Result<Response> {
    log_request(&req);

    // Optionally, get more helpful error messages written to the console in the case of a panic.
    utils::set_panic_hook();

    // Optionally, use the Router to handle matching endpoints, use ":name" placeholders, or "*name"
    // catch-alls to match on specific patterns. Alternatively, use `Router::with_data(D)` to
    // provide arbitrary data that will be accessible in each route via the `ctx.data()` method.
    let router = Router::new();

    // Add as many routes as your Worker needs! Each route will get a `Request` for handling HTTP
    // functionality and a `RouteContext` which you can use to  and get route parameters and
    // Environment bindings like KV Stores, Durable Objects, Secrets, and Variables.
    router
        .get("/", |req, _| {
            let url = req.url()?;
            let (width, height) = {
                let query_pairs = url.query_pairs();
                let width = query_pairs.into_iter().find_map(|(key, value)| {
                    if "width".eq(key.as_ref()) {
                        Some(value)
                    } else {
                        None
                    }
                });
                let height = query_pairs
                    .into_iter()
                    .find_map(|(key, value)| {
                        if "height".eq(key.as_ref()) {
                            Some(value)
                        } else {
                            None
                        }
                    })
                    .or(width.clone());
                match (width, height) {
                    (Some(w), Some(h)) => Ok((w, h)),
                    (None, _) => Err(MakerError::MissingParam("width")),
                    (_, _) => Err(MakerError::MissingParam("height")),
                }
            }?;
            let (width, height) = (
                width
                    .parse::<u16>()
                    .map_err(|_| MakerError::InvalidParam("width"))?,
                height
                    .parse::<u16>()
                    .map_err(|_| MakerError::InvalidParam("height"))?,
            );
            let labirynth = labyrinth_model::Labyrinth::new(width, height);

            let svg_tree = labyrinth_renderer::render_to_svg_tree(&labirynth);
            use usvg::TreeWriting;
            let svg = svg_tree.to_string(&usvg::XmlOptions::default());
            let mut response = Response::from_bytes(svg.into_bytes())?;
            let headers = response.headers_mut();
            headers.set("Content-Type", "image/svg+xml")?;
            Ok(response)
        })
        .get("/info", |_,_|{
            Response::ok("Generates labirynth of given width and height in squares.\n\nUsage: [host]/?width={width}[&height={height}]")
        })
        .run(req, env)
        .await
}
