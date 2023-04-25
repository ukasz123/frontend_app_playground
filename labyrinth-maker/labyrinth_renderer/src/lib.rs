use std::rc::Rc;

use labyrinth_model::*;

use usvg::*;

pub use usvg::Tree;

pub fn render_to_svg_tree(labyrinth: &Labyrinth) -> Tree {

    let passages= labyrinth.passages();

    let wall_len = 10.0;
    let wall_thickness = 2.0;

    let mut walls_path = PathData::new();

    let width = labyrinth.width() as usize;
    let height = labyrinth.height() as usize;
    // drawing the grid
    for i in 0..width {
        for j in 0..height {
            if i < width - 1 && !passages.contains(&Edge((i, j), (i + 1, j))) {
                walls_path.push_move_to(((i as f64) + 1.0) * wall_len, (j as f64) * wall_len);
                walls_path
                    .push_line_to(((i as f64) + 1.0) * wall_len, ((j as f64) + 1.0) * wall_len);
            }
            if j < height - 1 && !passages.contains(&Edge((i, j), (i, j + 1))) {
                walls_path.push_move_to((i as f64) * wall_len, ((j as f64) + 1.0) * wall_len);
                walls_path
                    .push_line_to(((i as f64) + 1.0) * wall_len, ((j as f64) + 1.0) * wall_len);
            }
        }
    }

    let mut outer_wall = PathData::new();
    outer_wall.push_move_to(wall_len, 0.0);
    outer_wall.push_line_to((width as f64) * wall_len, 0.0);
    outer_wall.push_line_to((width as f64) * wall_len, (height as f64) * wall_len);
    outer_wall.push_move_to(
        ((width as f64) - 1.0) * wall_len,
        (height as f64) * wall_len,
    );

    outer_wall.push_line_to(0.0, (height as f64) * wall_len);
    outer_wall.push_line_to(0.0, 0.0);

    let mut lab_walls_path_data = walls_path;
    lab_walls_path_data.push_path(&outer_wall);

    lab_walls_path_data.transform(Transform::new_translate(wall_len, wall_len));

    let labyrinth_walls = Path {
        id: "lab_walls".to_owned(),
        data: Rc::new(lab_walls_path_data),
        stroke: Some(Stroke {
            width: NonZeroPositiveF64::new(wall_thickness).unwrap(),
            linecap: LineCap::Round,
            ..Default::default()
        }),
        ..Default::default()
    };

    let svg_tree = Tree {
        size: Size::new(
            ((width as f64) + 2.0) * wall_len,
            ((height as f64) + 2.0) * wall_len,
        )
        .unwrap(),
        view_box: ViewBox {
            rect: Rect::new(
                0.0,
                0.0,
                ((width as f64) + 2.0) * wall_len,
                ((height as f64) + 2.0) * wall_len,
            )
            .unwrap(),
            aspect: AspectRatio::default(),
        },
        root: Node::new(NodeKind::Group(Group::default())),
    };

    svg_tree.root.append_kind(NodeKind::Path(labyrinth_walls));
    svg_tree
}
