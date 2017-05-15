-- Insert presentation by title, presenter first name, presenter last name, presentation level, and presentation location
DROP PROCEDURE spInsertPresentation;

CREATE PROCEDURE spInsertPresentation
  @presentationTitle VARCHAR(255),
  @presenterFirstName VARCHAR(255),
  @presenterLastName VARCHAR(255),
  @presentationLevel VARCHAR(45),
  @presentationLocation VARCHAR(255)
AS

  BEGIN TRY

    -- Verify that the event location exists
    IF NOT EXISTS (SELECT 1 FROM Event WHERE eventLocation = @presentationLocation)
      RAISERROR ('Event location does not exist.', 16, 1 );


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


    -- Insert the presentation
    INSERT INTO Presentation (title, idLevel) SELECT @presentationTitle, idLevel FROM PresentationLevel WHERE level = @presentationLevel;

    DECLARE @presentationId INT;
    SELECT TOP(1) @presentationId = idPresentation FROM Presentation WHERE title = @presentationTitle ORDER BY idPresentation DESC;


    -- Insert the presenter and presentation mapping
    INSERT INTO PresentationPresenterMapping (idPresentation, idPresenter) VALUES (@presentationId, @presenterId);


    -- Assign a random track to the presentation
    DECLARE @trackNum INT;
    SELECT TOP(1) @trackNum = idTrack FROM Track ORDER BY idTrack DESC;
    SELECT @trackNum = FLOOR(RAND()*(@trackNum)+1);

    INSERT INTO PresentationTrackMapping (idPresentation, idTrack) VALUES (@presentationId, @trackNum);


    -- Begin scheduling the presentation
    DECLARE @eventId INT;
    SELECT @eventId = idEvent FROM Event WHERE eventLocation = @presentationLocation;


    -- Find any room id that is not in the schedule table for this event
    DECLARE @roomId INT;
    DECLARE @scheduleTimeId INT;
    SELECT TOP(1) @scheduleTimeId = idScheduleTime FROM ScheduleTime ORDER BY scheduleTime ASC;
    SELECT TOP(1) @roomId = r.idRoom FROM Room r
        WHERE r.idRoom NOT IN (SELECT ps.idRoom FROM PresentationSchedule ps WHERE ps.idEvent = r.idEvent)
        AND r.idEvent = @eventId;


    -- If null, find the room with the earliest end time
    IF @roomId IS NULL
    BEGIN
      DECLARE @earliestRoom INT;
      DECLARE @bestScheduleTime TIME;
      SELECT TOP(1) @bestScheduleTime = scheduleTime FROM ScheduleTime ORDER BY scheduleTime DESC;

      DECLARE @i int;
      DECLARE @numRooms int;
      SET @i = 1;
      SELECT @numRooms = numRooms FROM Event WHERE idEvent = @eventId;

      DECLARE @scheduleTime TIME;
      SET @scheduleTime = '20:00';

      WHILE @i <= @numRooms
        BEGIN

          SELECT TOP(1) @scheduleTime = scheduleTime FROM (
            SELECT scheduleTime FROM ScheduleTime
              EXCEPT
            SELECT st.scheduleTime FROM ScheduleTime st
              INNER JOIN PresentationSchedule ps ON st.idScheduleTime = ps.idScheduleTime
              WHERE ps.idRoom = (SELECT idRoom FROM Room WHERE idEvent = @eventId AND roomNumber = @i) AND ps.idEvent = @eventId) schedule
          ORDER BY scheduleTime ASC;


          IF @scheduleTime < @bestScheduleTime
          BEGIN
            SET @earliestRoom = @i;
            SET @bestScheduleTime = @scheduleTime;

            SELECT @roomId = idRoom FROM Room WHERE idEvent = @eventId AND roomNumber = @i;
            SELECT @scheduleTimeId = idScheduleTime FROM ScheduleTime WHERE scheduleTime = @scheduleTime ORDER BY scheduleTime ASC;
          END

        SET @i = @i + 1
        SET @scheduleTime = '20:00';

        END

    END

    IF @roomId IS NULL
      RAISERROR ('Event schedule is full, no rooms available.', 16, 1 );


    INSERT INTO PresentationSchedule (idRoom, idEvent, idPresentation, idScheduleTime) VALUES
      (@roomId, @eventId, @presentationId, @scheduleTimeId);


  END TRY
  BEGIN CATCH

    SELECT ERROR_MESSAGE() AS errorMessage;

  END CATCH

GO