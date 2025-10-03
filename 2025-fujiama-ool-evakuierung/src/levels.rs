use anyhow::{Context, bail};
use std::io::Write;
use std::path::Path;

const LEVELS: [&[u8; 65]; 6] = [
    // 0123456789012345678901234567890123456789012345678901234567890123
    b"a[]              []                    []                        ",
    b"b[]  []          []    []              []                        ",
    b"c[]                          [][]                                ",
    b"d[][]                                                            ",
    b"e[]    []                                                        ",
    b"z[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]",
];

pub fn generate_levels(output_directory: &Path, simple: bool) -> anyhow::Result<()> {
    let (levels, shifts): (_, &[&str]) = if !simple {
        (
            &LEVELS[..5],
            &[
                "36a, 38a, 54a, 44a, 46a, 26a, 32a, 56a, 58a, 40a",
                "36b,  6a, 30a, 14a, 18a, 40a, 62b, 34a, 52a, 48a",
                "48b, 36b, 14b, 44b, 38b, 26b, 40b, 14b, 14a, 22a",
                "10b,  8c, 10a, 60b, 58c, 48a, 56b, 24c,  2a, 38b",
                "20b, 46b, 28c, 62b,  8c, 52c, 58c, 58a, 40d, 48b",
                "50d, 30e, 10c, 16c, 14c,  6a, 16a, 36d, 54e, 36a",
            ],
        )
    } else {
        (
            &LEVELS,
            &[
                "44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 40a",
                "44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 40a",
                "44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 40a",
                "44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 40a",
                "44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 40a",
                "44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 44z, 40a",
            ],
        )
    };

    let mut file = std::fs::File::create(output_directory.join("levels.asm"))
        .with_context(|| "Could not create levels.asm file")?;

    for level in levels {
        let (name, level) = level.split_first().unwrap();
        let name = char::from(*name);
        let mut value = Vec::with_capacity(128);
        value.extend_from_slice(level);
        value.extend_from_slice(level);
        writeln!(file, "    .pc = * \"level_{name}\"")?;
        writeln!(file, "level_{name}:")?;
        write!(file, "    .byte ")?;
        for (idx, level_char) in value.iter().enumerate() {
            if idx > 0 {
                write!(file, ", ")?;
            }
            match level_char {
                b' ' => write!(file, "$20")?,
                b'[' => write!(file, "$9e")?,
                b']' => write!(file, "$9f")?,
                _ => bail!("Level character {} not recognized", level_char),
            }
        }
        writeln!(file)?;
    }

    for (pos, shift) in shifts.iter().enumerate() {
        let shift = shift
            .split(',')
            .map(|s| {
                let s = s.trim();
                let (value, suffix) = s.split_at(s.len() - 1);
                format!("level_{suffix}+{value}")
            })
            .collect::<Vec<String>>();

        writeln!(file, "    .pc = * \"level{}_shift\"", pos + 1)?;
        writeln!(file, "level{}_shift_lo:", pos + 1)?;
        writeln!(file, "    .byte {}", shift.join(","))?;
        writeln!(file, "level{}_shift_hi:", pos + 1)?;
        writeln!(file, "    .byte {}>>8", shift.join(">>8,"))?;
    }

    Ok(())
}
