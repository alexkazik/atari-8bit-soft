use anyhow::{Context, anyhow};
use atari_8bit_tools::bundeled_files::copy_bundled_files;
use atari_8bit_tools::cli::Cli;
use atari_8bit_tools::xex::XexFile;
use atari_8bit_tools::{assembler, kick_assembler};
use std::convert::Infallible;
use std::path::PathBuf;

fn main() -> anyhow::Result<()> {
    Cli::<(), Infallible>::execute(
        |config, ()| {
            // copy basic file
            copy_bundled_files(config.output_directory).context("Failed to copy asm files")?;

            // format assembler files
            assembler::format(&[config.source_directory], true, false)?;

            // compile
            let output = kick_assembler::compile(&config, "main.asm")?;

            // create final binary (xex file)
            let target = PathBuf::from("summer.xex");
            let mut file = XexFile::create(&target).context("Failed to create file")?;
            file.write_segment(&output)?;
            file.run(
                output
                    .symbols
                    .get("start")
                    .ok_or(anyhow!("failed to get symbol \"start\""))?,
            )?;

            Ok(target)
        },
        |_, _, _| unreachable!(),
    )
}
