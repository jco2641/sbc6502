# sbc6502
A 65C02 based single board computer

Credits
- Ben Eater 6502 videos
- https://github.com/dbuchwald/6502/
- http://sbc.rictor.org/decoder.html
- Tons of other 6502 info pages and projects

## Development Environment in Windows
- Git 
  - Either git for windows, or in cygwin environment
- Latest Cygwin 
  - https://cygwin.com/setup-x86_64.exe
- Select Additional Cygwin Packages during install
  - gcc
  - make
  - pkg-config
  - xxd
- CC65 windows nightly snapshot 
  - https://sourceforge.net/projects/cc65/files/cc65-snapshot-win32.zip/download
  - extract zip file to a folder
- Build minipro from source (via git)
  - https://gitlab.com/DavidGriffith/minipro.git
  - cd minipro
  - run make, there will be warnings but it will build
- Add entries to path for locations of minipro and cc65/bin folder