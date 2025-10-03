use anyhow::Context;
use std::io::Write;
use std::path::Path;

const SCREEN1: [&[u8; 40]; 25] = [
    b"                                        ",
    b"                                        ",
    b"          DIE OOL-EVAKUIERUNG           ",
    b"                                        ",
    b"                                        ",
    b" IM FERNEN SONNENSYSTEM OOL LEBEN DIE   ",
    b" OOLEANS. DAS OOL-SONNENSYSTEM BESITZT  ",
    b" SECHS PLANETEN, DIE ALLE VON OOLEANS   ",
    b" BESIEDELT SIND. DOCH NUN STIRB DIE     ",
    b" SONNE DES SONNENSYSTEMS UND WIRD SICH  ",
    b" IN KURZER ZEIT AUFBLAEHEN UND DIE      ",
    b" PLANETEN VERSCHLINGEN. GELINGT ES      ",
    b" DIR, DIE OOLEANS ZU RETTEN?            ",
    b"                                        ",
    b" VERSCHIEBE TEILE DES TRANSPORTER-      ",
    b" STRAHLS SO, DASS DIE OOLEANS DURCH     ",
    b" IHN IN SICHERHEIT GEBRACHT WERDEN      ",
    b" KOENNEN. VIEL ERFOLG!                  ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"           DRUECKE FEUERKNOPF           ",
    b"                                        ",
    b"                                        ",
    b"       CODE: ALeX  GFX: RETROFAN        ",
];

const SCREEN2: [&[u8; 40]; 25] = [
    b"                                        ",
    b"                                        ",
    b"          DIE OOL-EVAKUIERUNG           ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"            SCHRITTE GESAMT:            ",
    b"                 000000                 ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"                                        ",
    b"           DRUECKE FEUERKNOPF           ",
    b"                                        ",
    b"                                        ",
    b"       CODE: ALeX  GFX: RETROFAN        ",
];

pub fn generate_screen(output_directory: &Path) -> anyhow::Result<()> {
    run(output_directory.join("screen1.bin"), &SCREEN1)?;
    run(output_directory.join("screen2.bin"), &SCREEN2)?;

    Ok(())
}

fn run<P: AsRef<Path>>(name: P, screen: &[&[u8; 40]; 25]) -> anyhow::Result<()> {
    let path = name.as_ref();
    let mut file = std::fs::File::create(path)
        .with_context(|| format!("Failed to create file {}", path.display()))?;

    for line in screen {
        file.write_all(*line)?;
    }

    Ok(())
}
