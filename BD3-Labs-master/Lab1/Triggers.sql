go
use WHiring;

go
CREATE TRIGGER VACANCY_INSERT
ON VACANCY
AFTER INSERT
AS
RAISERROR('New vacancy was added',16,0) WITH NOWAIT;