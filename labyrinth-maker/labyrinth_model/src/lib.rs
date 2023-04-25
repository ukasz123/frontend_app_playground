use itertools::{iproduct, Itertools};
use rand::{seq::SliceRandom, Rng};

#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
pub struct Edge(pub (usize, usize), pub (usize, usize));

impl PartialEq for Edge {
    fn eq(&self, other: &Self) -> bool {
        (self.0 == other.0 && self.1 == other.1) || (self.1 == other.0 && self.0 == other.1)
    }
}

#[derive(PartialEq)]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
pub struct Labyrinth {
    width: u16,
    height: u16,
    visited_cells: Vec<bool>,
    passages: Vec<Edge>,
}

impl Labyrinth {
    pub fn new(width: u16, height: u16) -> Labyrinth {
        let size = (width * height) as usize;
        let mut maze = Labyrinth {
            width,
            height,
            visited_cells: vec![false; size],
            passages: Vec::with_capacity(size * 2),
        };
        maze.push_visited(&[(0, 0)]);
        generate_maze_wilson(&mut maze);
        maze
    }

    fn index(&self, (x, y): &(u16, u16)) -> usize {
        (x + y * self.width) as usize
    }

    pub fn is_visited(&self, addr: &(u16, u16)) -> Option<&bool> {
        return self.visited_cells.get(self.index(addr));
    }

    pub fn push_visited(&mut self, src: &[(u16, u16)]) {
        for addr in src {
            let index = self.index(addr);
            if let Some(elem) = self.visited_cells.get_mut(index) {
                *elem = true;
            }
        }
    }

    pub fn push_passage(&mut self, edge: Edge) {
        self.passages.push(edge)
    }

    pub fn width(&self) -> u16 {
        self.width
    }

    pub fn height(&self) -> u16 {
        self.height
    }

    pub fn passages(&self) -> &Vec<Edge> {
        &self.passages
    }
}

fn generate_maze_wilson(maze: &mut Labyrinth) {
    let mut rng = rand::thread_rng();
    let mut all_coords = iproduct!(0..maze.width, 0..maze.height).collect::<Vec<_>>();
    all_coords.shuffle(&mut rng);
    let all_coords_iter = all_coords.iter();
    for target in all_coords_iter {
        if !maze.is_visited(target).unwrap_or(&true) {
            let path_to_maze = loop_erased_random_walk(&maze, &target).unwrap();
            maze.push_visited(&path_to_maze);
            let passages = path_to_maze
                .iter()
                .tuple_windows::<(_, _)>()
                .map(|(first, second)| {
                    Edge(
                        (first.0 as usize, first.1 as usize),
                        (second.0 as usize, second.1 as usize),
                    )
                });
            for passage in passages {
                maze.push_passage(passage)
            }
        }
    }
}

fn loop_erased_random_walk(maze: &Labyrinth, src: &(u16, u16)) -> Option<Vec<(u16, u16)>> {
    let mut current_path: Vec<(u16, u16)> = Vec::new();
    let mut head = src.clone();
    let mut rng = rand::thread_rng();
    while !maze.is_visited(&head).unwrap() {
        let existing_index = current_path.iter().position(|item| item == &head);

        match existing_index {
            Some(index) => {
                current_path.truncate(index + 1);
            }
            None => {
                current_path.push(head);
            }
        }

        let dir = rng.gen_range(0..4);
        let candidate = match (dir, head) {
            (0, (x, _)) if x > 0 => (head.0 - 1, head.1),
            (1, (x, _)) if x < maze.width - 1 => (head.0 + 1, head.1),
            (2, (_, y)) if y > 0 => (head.0, head.1 - 1),
            (3, (_, y)) if y < maze.height - 1 => (head.0, head.1 + 1),
            _ => head,
        };
        head = candidate;
    }
    current_path.push(head);
    Some(current_path)
}
#[cfg(test)]
mod tests {
    use crate::{loop_erased_random_walk, Labyrinth};

    #[test]
    fn maze_visited_works() {
        let mut maze = Labyrinth::new(4, 4);
        assert_eq!(Some(&false), maze.is_visited(&(0, 0)));
        maze.push_visited(&[(0, 0)]);
        assert_eq!(Some(&true), maze.is_visited(&(0, 0)));
        assert_eq!(Some(&false), maze.is_visited(&(1, 0)));
    }

    #[test]
    fn loop_erased_random_walk_works() {
        let mut maze = Labyrinth::new(4, 4);
        maze.push_visited(&[(0, 0)]);

        let walk = loop_erased_random_walk(&maze, &(3, 3));

        assert!(walk.is_some());
        if let Some(path) = walk {
            assert_eq!(Some(&(3, 3)), path.first());
            assert_eq!(Some(&(0, 0)), path.last());
            assert!(path.len() >= 4);
        }
    }

    #[test]
    fn loop_erased_random_walk_works_when_started_from_maze() {
        let mut maze = Labyrinth::new(4, 4);
        maze.push_visited(&[(0, 0)]);

        let walk = loop_erased_random_walk(&maze, &(0, 0));

        assert!(walk.is_some());
        if let Some(path) = walk {
            assert_eq!(Some(&(0, 0)), path.first());
            assert_eq!(Some(&(0, 0)), path.last());
            assert!(path.len() == 1);
        }
    }
}
