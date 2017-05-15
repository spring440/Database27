-- Stored procedure to add an event
DROP PROCEDURE spAddEvent;

CREATE PROCEDURE spAddEvent
  @date DATE,
  @eventName VARCHAR(255),
  @eventLocation VARCHAR(255),
  @eventRegion VARCHAR(255),
  @numRooms INT
AS

  BEGIN TRY

    INSERT INTO Event (eventDate, eventName, eventLocation, eventRegion, numRooms) VALUES
      (@date, @eventName, @eventLocation, @eventRegion, @numRooms);

    DECLARE @idEvent int;
    SELECT @idEvent = idEvent FROM Event WHERE eventName = @eventName;

    DECLARE @i int;
    DECLARE @rows_to_insert int;
    SET @i = 0;
    SET @rows_to_insert = @numRooms;

    WHILE @i < @rows_to_insert
      BEGIN
      INSERT INTO Room VALUES (@i + 1, @idEvent);
      SET @i = @i + 1
      END

  END TRY
  BEGIN CATCH
  END CATCH

GO
