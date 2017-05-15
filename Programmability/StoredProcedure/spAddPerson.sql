-- Stored procedure to add a person
DROP PROCEDURE spAddPerson;

CREATE PROCEDURE spAddPerson
  @firstName VARCHAR(45),
  @lastName VARCHAR(45),
  @street VARCHAR(255),
  @city VARCHAR(90),
  @postalCode VARCHAR(10),
  @country VARCHAR(90),
  @emailAddress VARCHAR(255)
AS

  INSERT INTO Person (firstName, lastName, street, city, postalCode, country, emailAddress) VALUES
    (@firstName, @lastName, @street, @city, @postalCode, @country, @emailAddress);

  DECLARE @idPerson INT;
  SELECT @idPerson = idPerson FROM Person WHERE firstName = @firstName AND lastName = @lastName AND emailAddress = @emailAddress;

  DECLARE @idRole INT;
  SELECT @idRole = idRole FROM PersonRole WHERE Role = 'Attendee';

  INSERT INTO RolesPersonMapping (idPerson, idRole) VALUES (@idPerson, @idRole);

GO