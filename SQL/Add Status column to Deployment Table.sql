alter table Deployment add [Status] varchar(50) not null default ('Active')
 Check (Status in ('Active','Completed','Cancelled') )