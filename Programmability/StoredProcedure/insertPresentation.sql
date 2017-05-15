-- Stored procedure to add a presenter to a Presentation
DROP PROCEDURE insertPresentation;

CREATE PROCEDURE insertPresentation
  @presenter VARCHAR(255),
  @presentationTitle VARCHAR(255)
AS

  BEGIN TRY

    DECLARE @presenterFirstName VARCHAR(255), @presenterLastName VARCHAR(255);

    SELECT @presenterFirstName = SUBSTRING( @presenter, 1, CHARINDEX(' ', @presenter) );
    SELECT @presenterLastName = SUBSTRING( @presenter, CHARINDEX(' ', @presenter) + 1, len(@presenter) - CHARINDEX(' ',@presenter) + 1 );

    -- Create the presenter if they do not already exist
    IF NOT EXISTS (SELECT 1 FROM Person WHERE firstName = @presenterFirstName AND lastName = @presenterLastName)
      INSERT INTO Person (firstName, lastName) VALUES (@presenterFirstName, @presenterLastName);

    DECLARE @presenterId INT;
    SELECT @presenterId = idPerson FROM Person WHERE firstName = @presenterFirstName AND lastName = @presenterLastName;


    -- Assign the presenter role to the presenter if they do not already have the role
    IF NOT EXISTS (SELECT 1 FROM vwPresenters WHERE idPerson = @presenterId)
    BEGIN
      INSERT INTO RolesPersonMapping (idPerson, idRole) SELECT @presenterId, idRole FROM PersonRole WHERE role = 'Presenter';
    END


    -- Assign a random level to the presentation
    DECLARE @presentationLevel INT;
    SELECT TOP(1) @presentationLevel = idLevel FROM PresentationLevel ORDER BY idLevel DESC;
    SELECT @presentationLevel = FLOOR(RAND()*(@presentationLevel)+1);


    -- Insert the presentation
    INSERT INTO Presentation (title, idLevel) VALUES (@presentationTitle, @presentationLevel);

    DECLARE @presentationId INT;
    SELECT TOP(1) @presentationId = idPresentation FROM Presentation WHERE title = @presentationTitle ORDER BY idPresentation DESC;


    -- Insert the presenter and presentation mapping
    INSERT INTO PresentationPresenterMapping (idPresentation, idPresenter) VALUES (@presentationId, @presenterId);


    -- Assign a random track to the presentation
    DECLARE @trackNum INT;
    SELECT TOP(1) @trackNum = idTrack FROM Track ORDER BY idTrack DESC;
    SELECT @trackNum = FLOOR(RAND()*(@trackNum)+1);

    INSERT INTO PresentationTrackMapping (idPresentation, idTrack) VALUES (@presentationId, @trackNum);

  END TRY
  BEGIN CATCH

    SELECT ERROR_MESSAGE() AS errorMessage;

  END CATCH

GO