-- Stored procedure to add a sponsor
DROP PROCEDURE spAddSponsor;

CREATE PROCEDURE spAddSponsor
    @sponsorName VARCHAR(255),
    @sponsorLevel VARCHAR(255)
AS

    BEGIN TRY

      IF NOT EXISTS (SELECT 1 FROM SponsorLevel WHERE sponsorLevel = @sponsorLevel)
        RAISERROR ('Sponsor level does not exist.', 16, 1);

      DECLARE @idSponsorLevel INT;

      SELECT @idSponsorLevel = idSponsorLevel FROM SponsorLevel WHERE sponsorLevel = @sponsorLevel;

      INSERT INTO Sponsor (sponsorName, idSponsorLevel) VALUES (@sponsorName, @idSponsorLevel);


    END TRY
    BEGIN CATCH
      SELECT ERROR_MESSAGE() AS errorMessage;
    END CATCH

GO