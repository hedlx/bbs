{ fetchFromGitHub, cmake, postgresql, stdenv }:
stdenv.mkDerivation rec {
  name = "pgquarrel-${version}";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "eulerto";
    repo = "pgquarrel";
    rev = "pgquarrel_0_5_0";
    sha256 = "06hc36gzzjhsis0dhcb0kdaszgcga49clyi7bgw68jzjyb698pkp";
  };
  buildInputs = [ cmake postgresql ];
  patchPhase = ''
    sed -i 's:set(LIBS ".{pgpath}/libpgport\.a"):target_link_libraries(pgquarrel ${postgresql}/lib/libpgport.a):' CMakeLists.txt
  '';
  CMAKE_LD_FLAGS = ''-L${postgresql}/lib'';
  meta = {
    description = "Tool to compare PostgreSQL database schemas (DDL)";
    homepage = https://github.com/eulerto/pgquarrel;
    license = stdenv.lib.licenses.bsd;
    maintainers = [ stdenv.lib.maintainers.xzfc ];
    platforms = [ "x86_64-linux" ];
  };
}
