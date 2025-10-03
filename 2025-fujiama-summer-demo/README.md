# "Summer"

## Quellcode

Der Code und die Grafiken werden unter der MIT Lizens (c) p1x3l.net zur Verfügung gestellt.

Habt viel spaß damit!

## Voraussetzung

* [rust](https://rustup.rs/) (getestet mit 1.89.0)
* [KickAssembler](https://theweb.dk/KickAssembler) (getestet mit v5.16)
* Java (für den Assembler)

## Konfiguration

Erstelle die Datei $HOME/.atari-8bit-tools.toml mit diesem Inhalt:

```ini
java = "java"
kick_assembler = "/path/to/KickAssembler/KickAss.jar"
atari800 = "atari800"
# optional argumente für atari800, diese werden vor dem Programmnamen eingefügt:
# atari800_args = ["-stretch", "3"]
```

Und passe den Pfad des KickAssemblers an.

Und ggf. auch von java und atari800 wenn diese nicht im $PATH sind.

## Compilieren

Bauen des Programms:

```shell
cargo r -- build
```

Bauen und den Emulator starten:

```shell
cargo r -- run
```
