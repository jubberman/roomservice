


--2 Create upload table



WITH librarylatest AS
(
	SELECT
		username,
		MAX(insertdate) AS 'latest'
	FROM
		cashlessDB.dbo.libraryload
	GROUP BY
		username
)




SELECT DISTINCT
	ead.firstname       AS 'Firstname',
	ead.surname			AS 'Surname',
	ead.Email			AS 'Email',
	ead.SchemeID        AS 'Scheme',
	ll.cardno			AS 'CardID',
	GETDATE()			AS 'StartDate',
    ead.PurseID			AS 'purse',
	ead.PropertyID		AS 'accountproperty',
	ead.PropertyGroupID AS 'PropertyGroupID'
INTO
	#studentinsert -- #studentinsert is our temporary table
FROM
	[dbo].[eandDrink2020] AS ead
	LEFT JOIN (
					select
						latest.username,
						lib.cardno,
						lib.email
					from
						librarylatest latest
						inner join cashlessDB.dbo.libraryload lib
							on latest.username = lib.username
							and latest.latest = lib.insertdate
			) AS ll
		ON ead.Email = ll.email


--3 Create the XML



    SELECT
		firstname        AS 'Firstname',
        surname            AS 'Surname',
        email            AS 'Email',
        'false'            AS 'CanEmail',
        'false'            AS 'CanSMS',
        ''                AS 'Password',
        'true'            AS 'AccountEnabled',
        'true'            AS 'AccountValidated',
        'NewAccount'    AS 'Status',
        scheme            AS 'SchemeID',
        CardID            AS 'CardID',
        startdate        AS 'StartDate',
        ( SELECT    purse AS 'PurseID',
                    0 AS 'Balance',
                    0 AS 'ValueToAdd' FROM #studentinsert WHERE #studentinsert.email = students.email
                    FOR XML PATH ('ImportPurse'), ROOT ('Purses'), type
        ),
        ( select PropertyGroupID, PropertyID from
        ( SELECT
				PropertyGroupID AS 'PropertyGroupID',
				accountproperty AS 'PropertyID'
			FROM #studentinsert
			WHERE #studentinsert.email = students.email
		) t
        FOR XML PATH ('ImportProperties'), ROOT ('PropertyList'), type
        )
FROM
	(SELECT DISTINCT CardID, firstname, surname, email, scheme, startdate FROM #studentinsert WHERE purse = 1) students
FOR XML PATH ('ImportAccount'), root('Accounts')