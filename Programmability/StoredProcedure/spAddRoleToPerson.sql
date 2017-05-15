-- Stored procedure to add a role to a person
DROP PROCEDURE spAddRoleToPerson;

CREATE PROCEDURE spAddRoleToPerson
  @idPerson int,
  @role varchar(45)
AS

  BEGIN TRY

    IF NOT EXISTS (SELECT 1 FROM Person WHERE idPerson = @idPerson)
      RAISERROR ('Person does not exist.', 16, 1);

    IF NOT EXISTS (SELECT 1 FROM PersonRole WHERE role = @role)
      RAISERROR ('Role does not exist.', 16, 1 );


    DECLARE @id int;
    SELECT @id = idPerson FROM Person WHERE idPerson = @idPerson;

    DECLARE @roleId int;
    SELECT @roleId = idRole FROM PersonRole WHERE Role = @role;

    INSERT INTO RolesPersonMapping (idPerson, idRole) VALUES (@id, @roleId);

  END TRY
  BEGIN CATCH

    SELECT ERROR_MESSAGE() AS errorMessage;

  END CATCH

GO