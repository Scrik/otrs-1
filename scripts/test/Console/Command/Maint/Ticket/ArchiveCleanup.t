# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $CommandObject = $Kernel::OM->Get('Kernel::System::Console::Command::Maint::Ticket::ArchiveCleanup');

my $ExitCode = $CommandObject->Execute();

# just check exit code
$Self->Is(
    $ExitCode,
    $Kernel::OM->Get('Kernel::Config')->Get('Ticket::ArchiveSystem') ? 0 : 1,
    "Maint::Ticket::ArchiveCleanup exit code",
);

# cleanup is done by RestoreDatabase

1;
