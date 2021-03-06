{ stdenv, fetchurl, bash, php }:

let

  version = "0.9.9";

in

stdenv.mkDerivation {
  inherit php;

  name = "psysh-${version}";

  buildInputs = [ bash php ];

  src = fetchurl {
    url = "https://github.com/bobthecow/psysh/releases/download/v${version}/psysh-v${version}.tar.gz";
    sha256 = "0knbib0afwq2z5fc639ns43x8pi3kmp85y13bkcl00dhvf46yinw";
  };

  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup
    tar xzf $src
    mv psysh psysh.phar
    php -dphar.readonly=0 ${builtins.toFile "fix-psysh.php" ''
      <?php
      $phar = new Phar('psysh.phar');
      $stub = $phar->getStub();
      $stub = preg_replace('/^(#!.+\n)?/', "#!" . getenv('php') . "/bin/php\n", $stub);
      $phar->setStub($stub);
    ''}
    mkdir -p $out/bin
    mv psysh.phar $out/bin/psysh
    chmod +x $out/bin/psysh
  '';

  meta = with stdenv.lib; {
    description = "A REPL for PHP";
    longDescription = ''
      PsySH is a runtime developer console, interactive debugger and REPL for PHP.
    '';
    homepage = http://psysh.org/;
    license = licenses.mit;
  };
}
