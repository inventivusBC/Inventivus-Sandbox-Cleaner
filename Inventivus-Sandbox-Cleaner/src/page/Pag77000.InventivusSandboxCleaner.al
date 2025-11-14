page 77000 "Inventivus Sandbox Cleaner"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Permissions = tabledata "Purch. Inv. Header" = rimd,
        tabledata "Sales Invoice Header" = rimd,
        tabledata "Cust. Ledger Entry" = rimd,
        tabledata "Change Log Entry" = rimd,
        tabledata "VAT Entry" = rimd,

        tabledata "Tenant Media" = rimd,
        tabledata "Tenant Media Set" = rimd,
        tabledata "Job Queue Log Entry" = rimd,
        tabledata "Sales Invoice Line" = rimd;

    layout
    {
        area(Content)
        {
            group(General)
            {

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeleteIntegrationEntries)
            {
                trigger OnAction()
                var
                    IntegrationSynchJob: Record "Integration Synch. Job";
                    Progress: Dialog;
                    Counter: BigInteger;
                    Text000: Label 'Counting: #1';
                    IntegrationSynchJobErrors: Record "Integration Synch. Job Errors";

                begin
                    if not Confirm('DeleteIntegrationEntries?') then
                        exit;
                    Counter := 0;
                    Progress.OPEN(Text000, Counter);

                    if IntegrationSynchJobErrors.FindSet() then
                        repeat
                            IntegrationSynchJobErrors.Delete(true);
                            Commit();
                            Counter := Counter + 1;
                            Progress.UPDATE(); // Update the field in the dialog.
                        until IntegrationSynchJobErrors.Next() = 0;
                    Commit();
                    Progress.UPDATE(); // Update the field in the dialog.

                    if IntegrationSynchJob.FindSet() then
                        repeat
                            IntegrationSynchJob.Delete(true);
                            Commit();
                            Counter := Counter + 1;
                            Progress.UPDATE(); // Update the field in the dialog.
                        until IntegrationSynchJob.Next() = 0;
                    Progress.CLOSE()
                end;
            }

            action(DeleteOldMedia)
            {
                Caption = 'Delete Old Files (Sandbox Only)';
                Image = Delete;
                ApplicationArea = All;

                trigger OnAction()
                var
                    EnvironmentInfo: Codeunit "Environment Information";
                    MediaRec: Record "Tenant Media";
                    Dialog: Dialog;
                    Counter: BigInteger;
                    Text000: Label 'Deleting old media: #1';
                    Text004: Label 'Deleting old job queue log entries: #1';
                    Text005: Label 'Deleting old change log entries: #1';
                    JobQueueLogEntry: Record "Job Queue Log Entry";
                    ChangeLogEntry: Record "Change Log Entry";

                begin
                    if EnvironmentInfo.IsProduction() then
                        Error('Deleting old media is only allowed in Sandbox environments.');

                    if not Confirm('Delete Old Log and Media Files older than 1 month?') then
                        exit;

                    MediaRec.SetRange(SystemCreatedAt, 0DT, CreateDateTime(Today() - 30, 0T));

                    Counter := 0;
                    Dialog.OPEN(Text000, Counter);

                    if MediaRec.FindSet() then
                        repeat
                            MediaRec.Delete(true);
                            Counter += 1;
                            Dialog.UPDATE();
                            Commit();
                        until MediaRec.Next() = 0;

                    Dialog.CLOSE();
                    Message('%1 media records older than 1 month deleted.', Counter);
                    // Deleting old Job Queue Log Entries
                    JobQueueLogEntry.SetRange("Start Date/Time", 0DT, CreateDateTime(Today() - 30, 0T));
                    Counter := 0;
                    Dialog.OPEN(Text004, Counter);
                    if JobQueueLogEntry.FindSet() then
                        repeat
                            JobQueueLogEntry.Delete(true);
                            Counter += 1;
                            Dialog.UPDATE();
                            Commit();
                        until JobQueueLogEntry.Next() = 0;
                    Dialog.CLOSE();
                    Message('%1 Job Queue Log Entry records older than 1 month deleted.', Counter);

                    // Deleting old Change Log Entries
                    ChangeLogEntry.SetRange("SystemCreatedAt", 0DT, CreateDateTime(Today() - 30, 0T));
                    Counter := 0;
                    Dialog.OPEN(Text005, Counter);
                    if ChangeLogEntry.FindSet() then
                        repeat
                            ChangeLogEntry.Delete(true);
                            Counter += 1;
                            Dialog.UPDATE();
                            Commit();
                        until ChangeLogEntry.Next() = 0;
                    Dialog.CLOSE();
                    Message('%1 Change Log Entry records older than 1 month deleted.', Counter);

                end;
            }
        }
    }
}