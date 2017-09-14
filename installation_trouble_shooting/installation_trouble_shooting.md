connect RTK and X11
[Installation information for R with GTK on Windows/Mac OS](https://gist.github.com/sebkopf/9405675)

```sh
~  R --version
R version 3.4.1 (2017-06-30) -- "Single Candle"
~ brew uninstall --force cairo --ignore-dependencies
~ brew install --with-x11 cairo
~ brew edit gtk+
def install
args = ["--disable-dependency-tracking",
"--disable-silent-rules",
"--prefix=#{prefix}",
"--disable-glibtest",
"--enable-introspection=yes",
# "--with-gdktarget=quartz",
"--with-gdktarget=x11",
"--enable-x11-backend"
#  "--disable-visibility"
]
~ brew install --build-from-source --verbose gtk+
~ export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib/pkgconfig/gtk+-2.0.pc:/opt/X11/lib/pkgconfig
~ R CMD INSTALL RGtk2_2.20.33.tar.gz

```