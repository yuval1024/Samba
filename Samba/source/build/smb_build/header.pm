# SMB Build System
# - create output for build.h
#
#  Copyright (C) Stefan (metze) Metzmacher 2004
#  Copyright (C) Jelmer Vernooij 2005
#  Released under the GNU GPL

package header;
use strict;

sub _add_define_section($)
{
	my $DEFINE = shift;
	my $output = "";

	$output .= "
/* $DEFINE->{COMMENT} */
#define $DEFINE->{KEY} $DEFINE->{VAL}
";

	return $output;
}

sub _prepare_build_h($)
{
	my $depend = shift;
	my @defines = ();
	my $output = "";

	foreach my $key (values %$depend) {
		my $DEFINE = ();
		next if ($key->{TYPE} ne "LIBRARY" and 
				 $key->{TYPE} ne "MODULE" and
				 $key->{TYPE} ne "SUBSYSTEM" and
			 	 $key->{TYPE} ne "BINARY");
		next unless defined($key->{INIT_FUNCTIONS});

		my $name = $key->{NAME};
		$name =~ s/-/_/g;
		$DEFINE->{COMMENT} = "$key->{TYPE} $key->{NAME} INIT";
		$DEFINE->{KEY} = "STATIC_$name\_MODULES";
		$DEFINE->{VAL} = "{ \\\n";
		foreach (@{$key->{INIT_FUNCTIONS}}) {
			$DEFINE->{VAL} .= "\t$_, \\\n";
			my $fn = $key->{INIT_FUNCTION_TYPE};
			unless(defined($fn)) { $fn = "NTSTATUS (*) (void)"; }
			$fn =~ s/\(\*\)/$_/;
			$output .= "$fn;\n";
		}

		$DEFINE->{VAL} .= "\tNULL \\\n }";

		push(@defines,$DEFINE);
	}

	#
	# loop over all BUILD_H define sections
	#
	foreach (@defines) { $output .= _add_define_section($_); }

	return $output;
}

###########################################################
# This function creates include/build.h from the SMB_BUILD 
# context
#
# create_build_h($SMB_BUILD_CTX)
#
# $SMB_BUILD_CTX -	the global SMB_BUILD context
#
# $output -		the resulting output buffer
sub create_smb_build_h($$)
{
	my ($CTX, $file) = @_;

	open(BUILD_H,">$file") || die ("Can't open `$file'\n");
	print BUILD_H "/* autogenerated by build/smb_build/main.pl */\n";
	print BUILD_H _prepare_build_h($CTX);
	close(BUILD_H);

	print __FILE__.": creating $file\n";
}
1;