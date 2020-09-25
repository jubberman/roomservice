--SELECT DISTINCT
--    [P_O].[FirstName] AS [firstname],
--    [P_O].[LastName] AS [lastname],
--    [P_O].ExternalSystemID AS [username],
--    CAST(P_RB.[LongRoomNumber] AS NVARCHAR(MAX)) AS [Residence],
--    CAST([Name] AS nvarchar(MAX)) AS [Session],--session name
--    --SUBSTRING([Name], 1, CHARINDEX(' ',[Name])),--returns a bit of shit but what can you do
--    --SUBSTRING([Name], CHARINDEX(' ', [Name]), CHARINDEX(' ', [Name])+1)-- this does return SOME shit (order by 5 desc) to see but is also kinda useful
--    he.Email
--FROM        [Booking].[Booking] B_B
--JOIN        [Person].[Occupant] P_O ON P_O.[OccupantID] = B_B.[PersonID]
--JOIN        [Business].[BusinessArea] B_BA ON B_BA.[BusinessAreaID] = B_B.[BusinessAreaID]
--INNER JOIN    [Booking].[LowLevelBooking] B_LLB ON B_LLB.[LowLevelBookingID] = B_B.[BookingID]
--INNER JOIN    [Booking].[LowLevelBookingPeriod] B_LLBP ON B_LLBP.[LowLevelBookingID] = B_LLB.[LowLevelBookingID]
--INNER JOIN    [Property].[RoomBed] P_RB ON P_RB.[RoomID] = B_LLB.[RoomID] AND P_RB.[BedID] = B_LLB.[BedID]
--INNER JOIN    [Property].[Room] P_R ON P_R.[RoomID] = B_LLB.[RoomID]



----get home contact details
--LEFT OUTER JOIN
--(select distinct d.occupantID, d.email
--from [Person].[ContactDetails] d
--inner join [Person].[OccupantContactDetails] o
--on d.ContactDetailsID = o.OccupantContactDetailsID
--where d.OccupantID is not null
--and o.ContactDetailsTypeID = 1
--) he
--ON P_O.[OccupantID] = he.[OccupantID]



--WHERE B_LLBP.[LowLevelBookingAllocationStateID] != 2
--AND B_LLB.[RoomOutOfServiceID] IS NULL AND ISNULL (B_B.[NoShow], 0) = 0
--and (
--P_RB.LongRoomNumber like 'Polden P_.__%' OR -- full £50 account property 7
--P_RB.LongRoomNumber like 'Brendon%' OR  -- full £50 account property 7
--P_RB.LongRoomNumber like 'Quad%' OR -- part £25 account property 8
--P_RB.LongRoomNumber like 'Woodland Court Permanent Shared%'OR  -- part £25 account property 8
--P_RB.LongRoomNumber like 'YMCA%'OR -- occasional £70 account property 14
--P_RB.LongRoomNumber like 'Conygre Spur%'OR --occasional £50 account property 9
--P_RB.LongRoomNumber like 'Cotswold TAcad%' --occasional £50 account property 9
--)
----and [P_CD].[Email] IS NOT NULL
----and [P_O].ExternalSystemID = 'cs897'
---- Edit this line for current session:
--and Name like '19/20 Autumn%'
---- Edit this line for current session:
--AND B_BA.[Summary] = 'Student'
--order by Residence asc



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
	#studentinsert3 -- #studentinsert is our temporary table
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


 /*

SELECT distinct        a.firstname        AS 'Firstname',
            a.lastname        AS 'Surname',
            isnull(l.email, a.username+'@bath.ac.uk')            AS 'Email',
            '16711842'        AS 'Scheme',
            l.cardno        AS 'CardID', -- *** JM NEED THIS
            GETDATE()        AS 'StartDate',

            CASE
				WHEN
					a.residence LIKE 'Quad%' OR a.residence LIKE 'Polden P_.__%' OR a.residence LIKE 'Brendon%' OR a.residence LIKE 'Woodland Court Permanent Shared%'
                    OR a.residence like 'YMCA%' OR a.residence like 'Conygre Spur%' OR a.residence like 'Cotswold TAcad%'
						THEN 1 -- purse 1 is "Eat and Drink Meal Plan" - see documentation for others, but we don't care if they're non
                ELSE 0 -- Eat and Drink, the WHERE statement prevents them coming in; this is just good coding
            END  AS 'purse',



            CASE -- this is for account property group 1, "Eat and Drink Meal Plan Catering Package"
                    WHEN a.residence  LIKE 'Polden P_.__%' OR a.residence LIKE 'Brendon%' THEN 7
                    WHEN a.residence LIKE 'Quad%' OR a.residence LIKE 'Woodland Court Permanent Shared%' THEN 8
                    WHEN a.residence like 'YMCA%' THEN 14
                    WHEN a.residence like 'Conygre Spur%' OR a.residence like 'Cotswold TAcad%' THEN 9
                    ELSE 0
            END        AS 'accountproperty'   --*** JM this needs pulled from  PropertyID



INTO        #studentinsert1 -- #studentinsert is our temporary table



FROM        [dbo].[EPOS_test_2019-09-16] a

            left outer join

				(select latest.username, lib.cardno , lib.email
				from librarylatest latest
				inner join cashlessDB.dbo.libraryload lib
				on latest.username = lib.username
				and latest.latest = lib.insertdate) l


            on a.username = l.username


 */

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
                    0 AS 'ValueToAdd' FROM #studentinsert1 WHERE #studentinsert1.email = students.email
                    FOR XML PATH ('ImportPurse'), ROOT ('Purses'), type
        ),
        ( select PropertyGroupID, PropertyID from
        ( SELECT
				PropertyGroupID AS 'PropertyGroupID',
				accountproperty AS 'PropertyID'
			FROM #studentinsert1
			WHERE #studentinsert1.email = students.email
		) t
        FOR XML PATH ('ImportProperties'), ROOT ('PropertyList'), type
        )
FROM
	(SELECT DISTINCT CardID, firstname, surname, email, scheme, startdate FROM #studentinsert1 WHERE purse = 1) students
FOR XML PATH ('ImportAccount'), root('Accounts')