-- Required procedure to select presentations by Budapest and track
DROP PROCEDURE selectPresentationsBudapest;

CREATE PROCEDURE selectPresentationsBudapest
  AS

    BEGIN TRY

      select * from vwPresentationSubjectLocation WHERE eventLocation = 'Budapest' ORDER BY subject;

    END TRY
    BEGIN CATCH
      SELECT ERROR_MESSAGE() AS errorMessage;
    END CATCH

GO