use crate::levels::generate_levels;
use crate::screen::generate_screen;
use anyhow::{Context, anyhow};
use atari_8bit_tools::bundeled_files::copy_bundled_files;
use atari_8bit_tools::cli::Cli;
use atari_8bit_tools::xex::XexFile;
use atari_8bit_tools::{assembler, kick_assembler};
use clap::Args;
use std::convert::Infallible;
use std::path::PathBuf;

mod levels;
mod screen;

#[derive(Args, Debug)]
struct MyArgs {
    /// build the simple levels
    #[arg(short, long)]
    simple: bool,
}

fn main() -> anyhow::Result<()> {
    Cli::<MyArgs, Infallible>::execute(
        |config, args| {
            // generate some files
            generate_screen(config.output_directory)?;
            generate_levels(config.output_directory, args.simple)?;

            // copy basic file
            copy_bundled_files(config.output_directory).context("Failed to copy asm files")?;

            // format assembler files
            assembler::format(&[config.source_directory], true, false)?;

            // compile
            let output = kick_assembler::compile(&config, "main.asm")?;

            // create final binary (xex file)
            let target = PathBuf::from("ool-evakuierung.xex");
            let mut file = XexFile::create(&target).context("Failed to create file")?;
            file.write_segment(&output)?;
            file.run(
                output
                    .symbols
                    .get("run")
                    .ok_or(anyhow!("failed to get symbol \"run\""))?,
            )?;

            Ok(target)
        },
        |_, _, _| unreachable!(),
    )
}
