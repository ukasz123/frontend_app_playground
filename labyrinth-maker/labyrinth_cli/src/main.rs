use std::io::Write;

use clap::Parser;
use labyrinth_model::Labyrinth;
use labyrinth_renderer::render_to_svg_tree;
use usvg::XmlOptions;
use usvg::TreeWriting;

fn main() {
    let cli = CLIArgs::parse();

    let output = cli.output.unwrap_or("labyrinth.svg".to_owned());

    let width = cli.width;
    let height = cli.height.unwrap_or(width);


    println!("Creating labyrinth of {width} and {height} size");

    let labirynth = Labyrinth::new(width, height);

    let svg_tree = render_to_svg_tree(&labirynth);

    let svg = svg_tree.to_string(&XmlOptions::default());

    let mut output_file = std::fs::File::create(output).unwrap();
    output_file.write_all(svg.as_bytes()).unwrap();
}


#[derive(Parser, Debug)]
struct CLIArgs {
    #[arg(short, default_value_t = 4)]
    width: u16,

    #[arg(long)]
    height: Option<u16>,

    output: Option<String>,
}
