package App::Rakudobrew::Shell::Csh;
use App::Rakudobrew::Shell;
our @ISA = "App::Rakudobrew::Shell";
use strict;
use warnings;
use 5.010;
use File::Spec::Functions qw(catdir splitpath);
use FindBin qw($RealBin $RealScript);

use App::Rakudobrew::Variables;
use App::Rakudobrew::Tools;
use App::Rakudobrew::VersionHandling;
use App::Rakudobrew::Build;

sub supports_hooking {
    my $self = shift;
    0;
}

sub install_note {
    my $brew_exec = catfile($RealBin, $brew_name);
    return <<EOT;
Load $brew_name automatically by adding

  eval "\$($brew_exec init Csh)"

to ~/.cshrc.
This can be easily done using:

  echo 'eval "\$($brew_exec init Csh)"' >> ~/.cshrc
EOT
}

sub shell_setenv_msg {
    my $self = shift;
    return <<EOT;
To (un)set a version locally in this running shell session use the following commands:
setenv $env_var YOUR_VERSION # set
unsetenv $env_var            # unset
EOT
}

sub get_init_code {
    my $self = shift;
    my $path = $ENV{PATH};
    $path = App::Rakudobrew::Shell::clean_path($path, $RealBin);
    $path = "$RealBin:$path";
    $path = join(':', $shim_dir, $path);
    return <<EOT;
setenv PATH "$path"
EOT

}

1;
