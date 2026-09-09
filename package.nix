{
  minimum-gnuapl-build ? false,

  lib,
  autoreconfHook,
  pkg-config,
  stdenv,
  fetchsvn,
  gtk3,
  libxcb,
  libx11,
  postgresql,
  sqlite,
  fftw,
  gsl,
  libpng,
  zlib,
  pcre2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnuapl";
  version = "2.0.0";

  src = fetchsvn {
    url = "http://svn.savannah.gnu.org/svn/apl/trunk";
    rev = "2112";
    sha256 = "BX0pDRwIzzvDlk6p534Q6OD6RTt/OpG5Swnum9hrBE8=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    postgresql.pg_config
  ];

  buildInputs = lib.optionals (!minimum-gnuapl-build) [
    gtk3
    libx11
    libxcb
    postgresql.lib
    sqlite
    fftw
    gsl
    libpng
    zlib
    pcre2
  ];

  configureFlags =
    lib.optionals minimum-gnuapl-build [ "--without-optional_libs" ]
    ++ lib.optionals (!minimum-gnuapl-build) [ "--with-sqlite3=${lib.getDev sqlite}" ];

  postInstall = ''
    cp -r support-files/ $out/share/doc/
    find $out/share/doc/support-files -name 'Makefile*' -delete
  '';

  meta = {
    description = "GNU APL interpreter";
    homepage = "https://www.gnu.org/software/apl/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "apl";

    longDescription = ''
      GNU APL is a free interpreter for the programming language APL, with an
      (almost) complete implementation of ISO standard 13751 aka.  Programming
      Language APL, Extended.  GNU APL was written and is being maintained by
      Jürgen Sauermann.
    '';
  };
})
