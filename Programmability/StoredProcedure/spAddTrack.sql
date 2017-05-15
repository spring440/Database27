-- Stored procedure to add a track to a Presentation
DROP PROCEDURE spAddTrack;

CREATE PROCEDURE spAddTrack
  @idPresentation int,
  @track varchar(45)
AS

  BEGIN TRY

    IF NOT EXISTS (SELECT 1 FROM Track WHERE subject = @track)
      RAISERROR ('Track does not exist.', 16, 1);

    IF NOT EXISTS (SELECT 1 FROM Presentation WHERE idPresentation = @idPresentation)
      RAISERROR ('Presentation does not exist.', 16, 1 );

    INSERT INTO PresentationTrackMapping VALUES (@idPresentation, (SELECT idTrack FROM Track WHERE subject = @track));

  END TRY
  BEGIN CATCH

    SELECT ERROR_MESSAGE() AS errorMessage;

  END CATCH

GO