# --
# HTML/Admin.pm - provides generic admin HTML output
# Copyright (C) 2001 Martin Edenhofer <martin+code@otrs.org>
# --
# $Id: Admin.pm,v 1.2 2001-12-26 20:06:50 martin Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::Output::HTML::Admin;

use strict;

use vars qw($VERSION);
$VERSION = '$Revision: 1.2 $';
$VERSION =~ s/^.*:\s(\d+\.\d+)\s.*$/$1/;

# --
sub AdminNavigationBar {
    my $Self = shift;
    my %Param = @_;

    # create & return output
    return $Self->Output(TemplateFile => 'AdminNavigationBar', Data => \%Param);
}
# --
sub ArticlePlain {
    my $Self = shift;
    my %Param = @_;

    # do some highlightings
    $Param{Text} =~ s/^((From|To|Cc|Subject|Reply-To|Organization|X-Company):.*)/<font color=\"red\">$1<\/font>/gm;
    $Param{Text} =~ s/^(Date:.*)/<FONT COLOR=777777>$1<\/font>/m;
    $Param{Text} =~ s/^((X-Mailer|User-Agent|X-OS):.*(Mozilla|Win?|Outlook|Microsoft|Internet Mail Service).*)/<blink>$1<\/blink>/gmi;
    $Param{Text} =~ s/(^|^<blink>)((X-Mailer|User-Agent|X-OS|X-Operating-System):.*)/<font color=\"blue\">$1$2<\/font>/gmi;
    $Param{Text} =~ s/^((Resent-.*):.*)/<font color=\"green\">$1<\/font>/gmi;
    $Param{Text} =~ s/^(From .*)/<font color=\"gray\">$1<\/font>/gm;
    $Param{Text} =~ s/^(X-OTRS.*)/<font color=\"#99BBDD\">$1<\/font>/gmi;

    # create & return output
    return $Self->Output(TemplateFile => 'AgentPlain', Data => \%Param);
}
# --
sub Note {
    my $Self = shift;
    my %Param = @_;

    # build ArticleTypeID string
    $Param{'NoteStrg'} = $Self->OptionStrgHashRef(
        Data => $Param{NoteTypes},
        Name => 'ArticleTypeID'
    );

    # create & return output
    return $Self->Output(TemplateFile => 'AgentNote', Data => \%Param);
}
# --
sub AgentPriority {
    my $Self = shift;
    my %Param = @_;

    # build ArticleTypeID string
    $Param{'OptionStrg'} = $Self->OptionStrgHashRef(
        Data => $Param{OptionStrg},
        Name => 'PriorityID'
    );

    # create & return output
    return $Self->Output(TemplateFile => 'AgentPriority', Data => \%Param);
}
# --
sub AgentClose {
    my $Self = shift;
    my %Param = @_;

    # build string
    $Param{'NextStatesStrg'} = $Self->OptionStrgHashRef(
        Data => $Param{NextStatesStrg},
        Name => 'StateID'
    );

    # build string
    $Param{'NoteTypesStrg'} = $Self->OptionStrgHashRef(
        Data => $Param{NoteTypesStrg},
        Name => 'NoteID'
    );

    # create & return output
    return $Self->Output(TemplateFile => 'AgentClose', Data => \%Param);
}
# --
sub AgentUtilForm {
    my $Self = shift;
    my %Param = @_;

    # create & return output
    return $Self->Output(TemplateFile => 'AgentUtilForm', Data => \%Param);
}
# --
sub AdminSessionTable {
    my $Self = shift;
    my %Param = @_;
    my $Output = '';

    foreach (sort keys %Param) {
      if (($_) && ($Param{$_}) && $_ ne 'SessionID') {
        if ($_  eq 'UserSessionStart') {
          my $Age = int((time() - $Param{UserSessionStart}) / 3600);
          $Param{UserSessionStart} = scalar localtime ($Param{UserSessionStart});
          $Output .= "[ " . $_ . " = $Param{$_} / $Age h ] <BR>\n";
        }
        else {
          $Output .= "[ " . $_ . " = $Param{$_} ] <BR>\n";
        }
      }
    }

    $Param{Output} = $Output;
    # create & return output
    return $Self->Output(TemplateFile => 'AdminSessionTable', Data => \%Param);
}
# --
sub AdminSelectBoxForm {
    my $Self = shift;
    my %Param = @_;

    return $Self->Output(TemplateFile => 'AdminSelectBoxForm', Data => \%Param);
} 
# --
sub AdminSelectBoxResult {
    my $Self = shift;
    my %Param = @_;
    my $DataTmp = $Param{Data};
    my @Datas = @$DataTmp;
    my $Output = '';
    foreach my $Data ( @Datas ) {
        $Output .= '<table cellspacing="0" cellpadding="3" border="0">';
        foreach (sort keys %$Data) {
            $$Data{$_} = $Self->Ascii2Html(Text => $$Data{$_}, Max => 200);
            $$Data{$_} = '<i>undef</i>' if (! defined $$Data{$_});
            $Output .= "<tr><td>$_:</td><td> = </td><td>$$Data{$_}</td></tr>\n";
        }
        $Output .= '</table>';
        $Output .= '<hr>';
   }

    $Param{Result} = $Output;
    # get output
    return $Self->Output(TemplateFile => 'AdminSelectBoxResult', Data => \%Param);
}
# --
sub AdminResponseForm {
    my $Self = shift;
    my %Param = @_;
    
    # build ValidID string
    $Param{'ValidOption'} = $Self->OptionStrgHashRef(
        Data => { 
          $Self->{DBObject}->GetTableData(
            What => 'id, name',
            Table => 'valid',
            Valid => 0,
          ) 
        },
        Name => 'ValidID',
        Selected => $Param{ValidID},
    );
 
    # build ResponseOption string
    $Param{'ResponseOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name, id',
            Valid => 0,
            Clamp => 1,
            Table => 'standard_response',
          )
        },
        Name => 'ID', 
        Size => 15,
        Selected => $Param{ID},
    );

    $Param{'Subaction'} = "Add" if (!$Param{'Subaction'});

    return $Self->Output(TemplateFile => 'AdminResponseForm', Data => \%Param);
}
# --
sub AdminQueueResponsesForm {
    my $Self = shift;
    my %Param = @_;
    my $UserData = $Param{FirstData};
    my %UserDataTmp = %$UserData;
    my $GroupData = $Param{SecondData};
    my %GroupDataTmp = %$GroupData;
    my $BaseLink = $Self->{Baselink} . "&Action=AdminQueueResponses";

    foreach (sort keys %UserDataTmp){
        $Param{AnswerQueueStrg} .= "<a href=\"$BaseLink&Subaction=Response&ID=$_\">$UserDataTmp{$_}</a><br>";
    }
    foreach (sort keys %GroupDataTmp){
        $Param{QueueAnswerStrg}.= "<a href=\"$BaseLink&Subaction=Queue&ID=$_\">$GroupDataTmp{$_}</a><br>";
    }

    return $Self->Output(TemplateFile => 'AdminQueueResponsesForm', Data => \%Param);
}
# --
sub AdminQueueResponsesChangeForm {
    my $Self = shift;
    my %Param = @_;
    my $FirstData = $Param{FirstData};
    my %FirstDataTmp = %$FirstData;
    my $SecondData = $Param{SecondData};
    my %SecondDataTmp = %$SecondData;
    my $Data = $Param{Data};
    my %DataTmp = %$Data;
    $Param{Type} = $Param{Type} || 'Response';
    my $NeType = 'Response';
    $NeType = 'Queue' if ($Param{Type} eq 'Response');

    foreach (sort keys %FirstDataTmp){
        $Param{OptionStrg0} .= "<B>$Param{Type}:</B> <A HREF=\"$Self->{Baselink}&Action=Admin$Param{Type}&Subaction=Change&ID=$_\">" .
        "$FirstDataTmp{$_}</A> (id=$_)<BR>";
        $Param{OptionStrg0} .= "<INPUT TYPE=\"hidden\" NAME=\"ID\" VALUE=\"$_\"><BR>\n";
    }

    $Param{OptionStrg0} .= "<B>$NeType:</B><BR> <SELECT NAME=\"IDs\" SIZE=10 multiple>\n";
    foreach my $ID (sort keys %SecondDataTmp){
       $Param{OptionStrg0} .= "<OPTION ";
       foreach (sort keys %DataTmp){
         if ($_ eq $ID) {
               $Param{OptionStrg0} .= 'selected';
         }
       }
      $Param{OptionStrg0} .= " VALUE=\"$ID\">$SecondDataTmp{$ID} (id=$ID)</OPTION>\n";
    }
    $Param{OptionStrg0} .= "</SELECT>\n";

    return $Self->Output(TemplateFile => 'AdminQueueResponsesChangeForm', Data => \%Param);
}
# --
sub AdminQueueForm {
    my $Self = shift;
    my %Param = @_;

    # build ValidID string
    $Param{'ValidOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name',
            Table => 'valid',
            Valid => 0,
          )
        },
        Name => 'ValidID',
        Selected => $Param{ValidID},
    );

    $Param{'GroupOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name',
            Table => 'groups',
            Valid => 0,
          )
        },
        Name => 'GroupID',
        Selected => $Param{GroupID},
    );

    $Param{'QueueOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name, id',
            Valid => 1,
            Clamp => 1,
            Table => 'queue',
          )
        },
        Name => 'QueueID',
        Size => 15,
        Selected => $Param{QueueID},
    );

    $Param{'SignatureOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name, id',
            Valid => 1,
            Clamp => 1,
            Table => 'signature',
          )
        },
        Name => 'SignatureID',
        Selected => $Param{SignatureID},
    );

    $Param{'SystemAddressOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, value0, value1',
            Valid => 1,
            Clamp => 1,
            Table => 'system_address',
          )
        },
        Name => 'SystemAddressID',
        Selected => $Param{SystemAddressID},
    );

    $Param{'SalutationOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name, id',
            Valid => 1,
            Clamp => 1,
            Table => 'salutation',
          )
        },
        Name => 'SalutationID',
        Selected => $Param{SalutationID},
    );

    $Param{'FollowUpOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name, id',
            Valid => 1,
            Clamp => 1,
            Table => 'follow_up_possible',
          )
        },
        Name => 'FollowUpID',
        Selected => $Param{FollowUpID},
    );


    $Param{'Subaction'} = "Add" if (!$Param{'Subaction'});

    return $Self->Output(TemplateFile => 'AdminQueueForm', Data => \%Param);
}
# --
sub AdminAutoResponseForm {
    my $Self = shift;
    my %Param = @_;

    # build ValidID string
    $Param{'ValidOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name',
            Table => 'valid',
            Valid => 0,
          )
        },
        Name => 'ValidID',
        Selected => $Param{ValidID},
    );

    $Param{'CharsetOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name, charset',
            Table => 'charset',
            Valid => 0,
          )
        },
        Name => 'CharsetID',
        Selected => $Param{CharsetID},
    );

    $Param{'AutoResponseOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name, id',
            Valid => 0,
            Clamp => 1,
            Table => 'auto_response',
          )
        },
        Name => 'ID',
        Size => 15,
        Selected => $Param{ID},
    );

    $Param{'TypeOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, name',
            Valid => 1,
            Clamp => 1,
            Table => 'auto_response_type',
          )
        },
        Name => 'TypeID',
        Selected => $Param{TypeID},
    );

    $Param{'SystemAddressOption'} = $Self->OptionStrgHashRef(
        Data => {
          $Self->{DBObject}->GetTableData(
            What => 'id, value0, value1',
            Valid => 1,
            Clamp => 1,
            Table => 'system_address',
          )
        },
        Name => 'AddressID',
        Selected => $Param{AddressID},
    );

    $Param{'Subaction'} = "Add" if (!$Param{'Subaction'});

    return $Self->Output(TemplateFile => 'AdminAutoResponseForm', Data => \%Param);
}
# --
sub AdminQueueAutoResponseTable {
    my $Self = shift;
    my %Param = @_;
    my $DataTmp = $Param{Data};
    my @Data = @$DataTmp;
    my $BaseLink = $Self->{Baselink} . "&Action=AdminQueueAutoResponse";
    $Param{DataStrg} = '<br>';

    foreach (@Data){
      my %ResponseData = %$_;
      $Param{DataStrg} .= "<B>*</B> <A HREF=\"$Self->{Baselink}&Action=AdminAutoResponse&Subaction=" .
        "Change&ID=$ResponseData{ID}\">$ResponseData{Name}</A> ($ResponseData{Type}) <BR>";
    }
    if (@Data == 0) {
      $Param{DataStrg}.= "Sorry, <FONT COLOR=\"RED\">no</FONT> auto responses set!\n";
    }

    return $Self->Output(TemplateFile => 'AdminQueueAutoResponseTable', Data => \%Param);
}
# --
sub AdminQueueAutoResponseChangeForm {
    my $Self = shift;
    my %Param = @_;

    return $Self->Output(TemplateFile => 'AdminQueueAutoResponseForm', Data => \%Param);
}
# --
sub AdminQueueAutoResponseChangeFormHits {
    my $Self = shift;
    my %Param = @_;
    my $SessionID = $Self->{SessionID} || '';
    my $Type = $Param{Type} || '?';
    my $Data = $Param{Data};
    my $SelectedID = $Param{SelectedID} || -1;
    my $Output = '';
($Output .= <<EOF);
<BR>
  <B>${\$Self->{LanguageObject}->Get("Change")} 
    "${\$Self->{LanguageObject}->Get($Type)}" 
    ${\$Self->{LanguageObject}->Get("settings")}</B>: 
  <BR>

EOF

    $Output .= $Self->OptionStrgHashRef(
        Name => 'IDs',
        Selected => $SelectedID,
        Data => $Data,
        Size => 3,
    );

    return $Output;
}
# --

1;
 
