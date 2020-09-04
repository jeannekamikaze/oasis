cflags{
	'-std=c11', '-Wall', '-Wpedantic',
	'-Wno-overflow',  -- ioctl opcode conversion
	'-include $outdir/config.h',
	'-D _DEFAULT_SOURCE',
	'-D _FIDO_INTERNAL',
	'-I $srcdir/src',
	'-isystem $basedir/pkg/openbsd/include',
	'-isystem $builddir/pkg/bearssl/include',
	'-isystem $builddir/pkg/libcbor/include',
	'-isystem $builddir/pkg/linux-headers/include',
}

pkg.hdrs = copy('$outdir/include', '$srcdir/src', {
	'fido.h',
	'fido/credman.h',
	'fido/err.h',
	'fido/param.h',
	'fido/types.h',
})
pkg.deps = {
	'$outdir/config.h',
	'pkg/bearssl/headers',
	'pkg/libcbor/headers',
	'pkg/linux-headers/headers',
}

build('cat', '$outdir/config.h', {
	'$builddir/probe/HAVE__THREAD_LOCAL',
	'$dir/config.h',
})

lib('libfido2.a', [[
	src/(
		aes256.c
		assert.c
		authkey.c
		bio.c
		blob.c
		buf.c
		cbor.c
		cred.c
		credman.c
		dev.c
		ecdh.c
		eddsa.c
		err.c
		es256.c
		hid.c
		info.c
		io.c
		iso7816.c
		log.c
		pin.c
		reset.c
		rs256.c
		u2f.c

		hid_linux.c
	)
	$builddir/pkg/bearssl/libbearssl.a
	$builddir/pkg/libcbor/libcbor.a
	$builddir/pkg/openbsd/libbsd.a
]])

lib('libcommon.a', [[tools/(base64.c util.c)]])

exe('fido2-cred', [[
	tools/(
		fido2-cred.c
		cred_make.c
		cred_verify.c
	)
	libcommon.a
	libfido2.a.d
]])
file('bin/fido2-cred', '755', '$outdir/fido2-cred')
man{'man/fido2-cred.1'}

exe('fido2-token', [[
	tools/(
		fido2-token.c
		bio.c
		credman.c
		pin.c
		token.c
	)
	libcommon.a
	libfido2.a.d
]])
file('bin/fido2-token', '755', '$outdir/fido2-token')
man{'man/fido2-token.1'}

fetch 'git'
