# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Ticket::Event::Test;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Data Event Config)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }
    for (qw(TicketID)) {
        if ( !$Param{Data}->{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_ in Data!"
            );
            return;
        }
    }

    if ( $Param{Event} eq 'TicketCreate' ) {

        # get ticket object
        my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $Param{Data}->{TicketID},
            DynamicFields => 0,
        );

        if ( $Ticket{State} eq 'Test' ) {

            # do some stuff
            $TicketObject->HistoryAdd(
                TicketID     => $Param{Data}->{TicketID},
                CreateUserID => $Param{UserID},
                HistoryType  => 'Misc',
                Name         => 'Some Info about Changes!',
            );
        }
    }
    elsif ( $Param{Event} eq 'TicketQueueUpdate' ) {

        # get ticket object
        my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $Param{Data}->{TicketID},
            DynamicFields => 0,
        );

        if ( $Ticket{Queue} eq 'Test' ) {

            # do some stuff
            $TicketObject->HistoryAdd(
                TicketID     => $Param{Data}->{TicketID},
                CreateUserID => $Param{UserID},
                HistoryType  => 'Misc',
                Name         => 'Some Info about Changes!',
            );
        }
    }

    return 1;
}

1;
