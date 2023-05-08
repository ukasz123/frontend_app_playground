use std::ops::Deref;

use leptos::*;

use labyrinth_model::*;
use labyrinth_renderer::*;
use usvg::{Node, NodeKind, PathSegment};

fn main() {
    mount_to_body(|cx| view! {cx, <App/>})
}

#[component]
fn App(cx: Scope) -> impl IntoView {
    let (width, set_width) = create_signal::<u16>(cx, 10);
    let width_str = move || width.get().to_string();
    let (height, set_height) = create_signal::<u16>(cx, 10);
    let height_str = move || height.get().to_string();

    let (local_renderer, set_local_renderer) = create_signal::<bool>(cx, false);

    view! {cx,
    <h1>"Labyrinth generator"</h1>
    <form>
        <div>
            <label>"Width: "</label>
            <input type="number" on:input=move |ev| {
                let txt = event_target_value(&ev);
                if let Ok(v) = txt.parse::<u16>() {
                    if v > 1 {
                        log!("Updating width to {v}");
                        set_width.set(v);
                    }
                }
            }
            prop:value=width_str/>
        </div>
        <div>
            <label>"Height: "</label>
            <input type="number" on:input=move |ev| {
                let txt = event_target_value(&ev);
                if let Ok(v) = txt.parse::<u16>() {
                    if v > 1{
                        log!("Updating height to {v}");
                        set_height.set(v);
                    }
                }
            }
            prop:value=height_str/>
        </div>
        <div>
            <label>"Local generator: "</label>
            <input type="checkbox" on:change=move |ev| {
                let txt = event_target_checked(&ev);
                set_local_renderer.set(txt);
            }/>
        </div>
    </form>
    <hr/>

    <div>
        "Labyrinth "{width} "/" {height} ":"
        <Show
            when=move || local_renderer.get()
            fallback=move |cx| view!{cx, <LabyrinthSvgImgView  width=width height=height/> }
        >
            <LabyrinthSvgView width=width height=height/>
        </Show>
    </div>
    }
}

#[component]
fn LabyrinthSvgImgView(
    cx: Scope,
    width: ReadSignal<u16>,
    height: ReadSignal<u16>,
) -> impl IntoView {
    let svg_src = move || {
        format!(
            "https://labyrinth-maker-worker.ukasz-apps.workers.dev?width={}&height={}",
            width.get(),
            height.get()
        )
    };
    view! {cx,
        <div id="labyrinth-preview">
            <div><img prop:src={svg_src}/></div>
        </div>
    }
}

#[component]
fn LabyrinthSvgView(cx: Scope, width: ReadSignal<u16>, height: ReadSignal<u16>) -> impl IntoView {
    let size = move || (width.get(), height.get());

    let async_labyrinth = create_local_resource(cx, size, |s| async move {
        log!("Generating labyrinth of size: ({}, {}).", s.0, s.1);
        create_labirynth(s).await
    });

    view! {
       cx, <div id="labyrinth-preview">{move || match async_labyrinth.with(cx, |labyrinth| {
        let svg_tree = render_to_svg_tree(&labyrinth);
        render_to_svg_view(cx, &svg_tree)
       }){
        Some(svg_view) => view!{cx, {svg_view}}.into_view(cx),
        None => view! {cx, "Generating labyrinth..."}.into_view(cx)
       }}</div>
    }
}

async fn create_labirynth(size: (u16, u16)) -> Labyrinth {
    Labyrinth::new(size.0, size.1)
}

fn render_to_svg_view(cx: Scope, lab: &Tree) -> impl IntoView {
    view! { cx,
        <div>
            <svg viewBox={format!("0 0 {} {}", lab.view_box.rect.width(), lab.view_box.rect.height())}>
            {
                let node = &lab.root;
                render_node_to_svg_view(cx, node)
            }
            </svg>
        </div>
    }
}

fn render_node_to_svg_view(cx: Scope, node: &Node) -> impl IntoView {
    view! {cx,
        {
            let inner_node = node.borrow();
            let inner_node = inner_node.deref();
            let element = match inner_node {

                NodeKind::Group(group) => {
                    view! {cx,
                        <g id={group.id.clone()}>
                        {
                           node.children().map(|child|
                            render_node_to_svg_view(cx, &child)
                           ).collect::<Vec<_>>()

                        }
                        </g>
                    }.into_any()
                },
                NodeKind::Path(path) => {
                    let default_stroke = usvg::Stroke::default();
                    let stroke = path.stroke.as_ref();
                    let stroke = stroke.unwrap_or(&default_stroke);
                    let fill = path.fill.as_ref();
                    view! {
                        cx, <path id={path.id.clone()} d={path.data.segments().map(|segment|{
                            match segment {
                                PathSegment::MoveTo { x, y } => {format!("M {x} {y}")},
                                PathSegment::LineTo {x,y} => {format!("L {x} {y}")},
                                PathSegment::CurveTo {x1,
                                    y1,
                                    x2,
                                    y2,
                                    x,
                                    y} => format!("C {x} {y} {x1} {y1} {x2} {y2}"),
                                    PathSegment::ClosePath => format!("Z"),
                            }
                        } ).collect::<Vec<_>>().join(" ")}
                        stroke={get_color_string(&stroke.paint)}
                        stroke-width={
                            stroke.width.get()
                        }
                        stroke-linecap={match stroke.linecap {
                            usvg::LineCap::Butt => "butt",
                            usvg::LineCap::Round => "round",
                            usvg::LineCap::Square => "square",
                        }}
                        fill={fill.map_or("none".to_owned(), |fill| get_color_string(&fill.paint))}
                        > </path>
                    }.into_any()
                },
                NodeKind::Image(_) => todo!(),
                NodeKind::Text(_) => todo!(),
            };
        element
    }
    }
}

fn get_color_string(paint: &usvg::Paint) -> String {
    match paint {
        usvg::Paint::Color(color) => {
            format!("#{:02x}{:02x}{:02x}", color.red, color.green, color.blue)
        }
        _ => {
            format!("#000000")
        }
    }
}
