USE master;
GO

IF DB_ID('TechTalentHub') IS NOT NULL
BEGIN
    ALTER DATABASE TechTalentHub SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TechTalentHub;
END
GO

CREATE DATABASE TechTalentHub;
GO

USE TechTalentHub;
GO

-- =============================================
-- TABLE DEFINITIONS
-- =============================================

CREATE TABLE [User] (
    [UserId] NVARCHAR(128) NOT NULL,
    [Email] NVARCHAR(256) NOT NULL,
    [PasswordHash] NVARCHAR(256) NOT NULL,
    [RegistrationDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [LastLoginDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [AccountStatus] NVARCHAR(10) NOT NULL DEFAULT N'Active',
    [UserType] NVARCHAR(10) NOT NULL,
    PRIMARY KEY ([UserId]),
    CONSTRAINT [UQ_User_Email] UNIQUE ([Email]),
    CONSTRAINT [CK_User_Email] CHECK ([Email] LIKE N'%@%.%'),
    CONSTRAINT [CK_User_AccountStatus] CHECK ([AccountStatus] IN (N'Active', N'Disabled', N'Banned')),
    CONSTRAINT [CK_User_UserType] CHECK ([UserType] IN (N'JobSeeker', N'Company', N'Admin'))
);
GO

CREATE TABLE [Admin] (
    [AdminId] NVARCHAR(128) NOT NULL,
    [AdminName] NVARCHAR(128) NOT NULL,
    [AdminRole] NVARCHAR(10) NOT NULL,
    [DateAssigned] DATETIME2 NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY ([AdminId]),
    CONSTRAINT [FK_Admin_AdminId_User]
        FOREIGN KEY ([AdminId]) REFERENCES [User]([UserId])
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT [CK_Admin_AdminRole] CHECK ([AdminRole] IN (N'SuperAdmin', N'Moderator', N'Support', N'Auditor'))
);
GO

CREATE TABLE [Company] (
    [CompanyID] NVARCHAR(128) NOT NULL,
    [FounderYear] SMALLINT NULL,
    [VerificationStatus] NVARCHAR(10) NOT NULL DEFAULT N'PENDING',
    [LogoURL] NVARCHAR(512) NULL,
    [CompanySize] NVARCHAR(10) NULL,
    [Industry] NVARCHAR(128) NULL,
    [CompanyName] NVARCHAR(256) NOT NULL,
    [CompanyDescription] NVARCHAR(MAX) NULL,
    [CompanyWebsite] NVARCHAR(512) NULL,
    PRIMARY KEY ([CompanyID]),
    CONSTRAINT [FK_Company_CompanyID_User]
        FOREIGN KEY ([CompanyID]) REFERENCES [User]([UserId])
        ON UPDATE CASCADE 
        ON DELETE NO ACTION,
    CONSTRAINT [CK_Company_VerificationStatus] CHECK ([VerificationStatus] IN (N'ACCEPTED',N'PENDING',N'REJECTED')),
    CONSTRAINT [CK_Company_CompanySize] CHECK ([CompanySize] IN (N'Small',N'Medium',N'Large',N'Enterprise'))
);
GO

-- FIX: Reduce Address column size to fit within 900 bytes limit for clustered index
CREATE TABLE [CompanyLocation] (
    [CompanyID] NVARCHAR(128) NOT NULL,
    [Address] NVARCHAR(300) NOT NULL,  -- Changed from 600 to 300
    PRIMARY KEY ([CompanyID], [Address]),
    CONSTRAINT [FK_CompanyLocation_CompanyID_Company]
        FOREIGN KEY ([CompanyID]) REFERENCES [Company]([CompanyID])
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);
GO
CREATE INDEX [IX_CompanyLocation_Address] ON [CompanyLocation]([Address]);
GO

CREATE TABLE [JobSeeker] (
    [JobSeekerID] NVARCHAR(128) NOT NULL,
    [FirstName] NVARCHAR(100) NOT NULL,
    [LastName] NVARCHAR(100) NOT NULL,
    [PhoneNumber] NVARCHAR(40) NULL,
    [CurrentLocation] NVARCHAR(255) NULL,
    [Gender] NVARCHAR(10) NULL,
    [DateOfBirth] DATE NULL,
    [ExperienceLevel] NVARCHAR(64) NULL,
    [ProfileSummary] NVARCHAR(MAX) NULL,
    [CVFileURL] NVARCHAR(512) NULL,
    PRIMARY KEY ([JobSeekerID]),
    CONSTRAINT [FK_JobSeeker_JobSeekerID_User]
        FOREIGN KEY ([JobSeekerID]) REFERENCES [User]([UserId])
        ON UPDATE CASCADE 
        ON DELETE NO ACTION,
    CONSTRAINT [CK_JobSeeker_Gender] CHECK ([Gender] IN (N'MALE',N'FEMALE',N'OTHER'))
);
GO

CREATE TABLE [Skill] (
    [SkillID] INT NOT NULL IDENTITY(1,1),
    [SkillName] NVARCHAR(160) NOT NULL,
    [SkillCategory] NVARCHAR(120) NULL,
    [PopularityScore] INT NULL DEFAULT 0,
    PRIMARY KEY ([SkillID]),
    CONSTRAINT [UQ_Skill_SkillName] UNIQUE ([SkillName]),
    CONSTRAINT [CK_Skill_PopularityScore] CHECK ([PopularityScore] >= 0 AND [PopularityScore] <= 100)
);
GO

CREATE TABLE [JobSeekerSkill] (
    [JobSeekerID] NVARCHAR(128) NOT NULL,
    [SkillID] INT NOT NULL,
    [ProficiencyLevel] NVARCHAR(12) NOT NULL,
    [YearOfExperience] DECIMAL(4,1) NULL DEFAULT 0,
    PRIMARY KEY ([JobSeekerID], [SkillID]),
    CONSTRAINT [FK_JobSeekerSkill_JobSeekerID_JobSeeker]
        FOREIGN KEY ([JobSeekerID]) REFERENCES [JobSeeker]([JobSeekerID])
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT [FK_JobSeekerSkill_SkillID_Skill]
        FOREIGN KEY ([SkillID]) REFERENCES [Skill]([SkillID])
        ON UPDATE CASCADE 
        ON DELETE NO ACTION,
    CONSTRAINT [CK_JSS_Proficiency] CHECK ([ProficiencyLevel] IN (N'Beginner',N'Intermediate',N'Advanced',N'Expert'))
);
GO
CREATE INDEX [IX_JobSeekerSkill_SkillID] ON [JobSeekerSkill]([SkillID]);
GO

CREATE TABLE [Experience] (
    [ExperienceID] INT NOT NULL IDENTITY(1,1),
    [JobSeekerID] NVARCHAR(128) NOT NULL,
    [CompanyID] NVARCHAR(128) NOT NULL,
    [JobTitle] NVARCHAR(255) NOT NULL,
    [ExperienceType] NVARCHAR(10) NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NULL,
    [Description] NVARCHAR(MAX) NULL,
    PRIMARY KEY ([ExperienceID]),
    CONSTRAINT [UQ_Experience_JobSeeker_Company_JobTitle] UNIQUE ([JobSeekerID], [CompanyID], [JobTitle]),
    CONSTRAINT [FK_Experience_JobSeekerID_JobSeeker]
        FOREIGN KEY ([JobSeekerID]) REFERENCES [JobSeeker]([JobSeekerID])
        ON UPDATE NO ACTION  -- Changed from CASCADE
        ON DELETE CASCADE,
    CONSTRAINT [FK_Experience_CompanyID_Company]
        FOREIGN KEY ([CompanyID]) REFERENCES [Company]([CompanyID])
        ON UPDATE NO ACTION  
        ON DELETE NO ACTION,
    CONSTRAINT [CK_Experience_Dates] CHECK ([EndDate] IS NULL OR [EndDate] >= [StartDate]),
    CONSTRAINT [CK_Exp_Type] CHECK ([ExperienceType] IN (N'Internship',N'FullTime',N'PartTime',N'Contract',N'Freelance'))
);
GO
CREATE INDEX [IX_Experience_JobTitle] ON [Experience]([JobTitle]);
GO
CREATE INDEX [IX_Experience_CompanyID] ON [Experience]([CompanyID]);
GO

CREATE TABLE [Job] (
    [JobID] NVARCHAR(128) NOT NULL,
    [CompanyID] NVARCHAR(128) NOT NULL,
    [JobTitle] NVARCHAR(255) NOT NULL,
    [JobDescription] NVARCHAR(MAX) NOT NULL,
    [EmploymentType] NVARCHAR(10) NOT NULL,
    [ExperienceRequired] SMALLINT NULL DEFAULT 0,
    [SalaryMin] DECIMAL(15,2) NULL,
    [SalaryMax] DECIMAL(15,2) NULL,
    [Location] NVARCHAR(255) NULL,
    [OpeningCount] INT NOT NULL DEFAULT 1,
    [PostedDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [ApplicationDeadline] DATETIME2 NULL,
    [JobStatus] NVARCHAR(10) NOT NULL DEFAULT 'Open',
    PRIMARY KEY ([JobID]),
    CONSTRAINT [FK_Job_CompanyID_Company]
        FOREIGN KEY ([CompanyID]) REFERENCES [Company]([CompanyID])
        ON UPDATE CASCADE 
        ON DELETE NO ACTION,
    CONSTRAINT [CK_Job_Salary] CHECK ([SalaryMax] IS NULL OR [SalaryMin] IS NULL OR [SalaryMax] >= [SalaryMin]),
    CONSTRAINT [CK_Job_Deadline] CHECK ([ApplicationDeadline] IS NULL OR [ApplicationDeadline] > [PostedDate]),
    CONSTRAINT [CK_Job_ExperienceRequired] CHECK ([ExperienceRequired] >= 0),
    CONSTRAINT [CK_Job_EmpType] CHECK ([EmploymentType] IN (N'FullTime',N'PartTime',N'Contract',N'Internship',N'Remote')),
    CONSTRAINT [CK_Job_Status] CHECK ([JobStatus] IN (N'Open',N'Closed',N'OnHold',N'Filled'))
);
GO
CREATE INDEX [IX_Job_CompanyID] ON [Job]([CompanyID]);
GO
CREATE INDEX [IX_Job_PostedDate] ON [Job]([PostedDate]);
GO

CREATE TABLE [JobRequireSkill] (
    [JobID] NVARCHAR(128) NOT NULL,
    [SkillID] INT NOT NULL,
    [ProficiencyLevel] NVARCHAR(12) NOT NULL,
    [IsRequired] BIT NOT NULL DEFAULT 1,
    PRIMARY KEY ([JobID], [SkillID]),
    CONSTRAINT [FK_JobRequireSkill_JobID_Job]
        FOREIGN KEY ([JobID]) REFERENCES [Job]([JobID])
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT [FK_JobRequireSkill_SkillID_Skill]
        FOREIGN KEY ([SkillID]) REFERENCES [Skill]([SkillID])
        ON UPDATE CASCADE 
        ON DELETE NO ACTION,
    CONSTRAINT [CK_JRS_Proficiency] CHECK ([ProficiencyLevel] IN (N'Beginner',N'Intermediate',N'Advanced',N'Expert'))
);
GO
CREATE INDEX [IX_JobRequireSkill_SkillID] ON [JobRequireSkill]([SkillID]);
GO

-- FIX: Changed FK_Application_JobID_Job to NO ACTION to avoid cascade cycles
CREATE TABLE [Application] (
    [ApplicationID] INT NOT NULL IDENTITY(1,1),
    [JobSeekerID] NVARCHAR(128) NOT NULL,
    [JobID] NVARCHAR(128) NOT NULL,
    [ApplicationDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [CoverLetterURL] NVARCHAR(512) NULL,
    [InterviewDate] DATETIME2 NULL,
    [InterviewNote] NVARCHAR(MAX) NULL,
    [ApplicationStatus] NVARCHAR(12) NOT NULL DEFAULT N'Submitted',
    [RejectedReason] NVARCHAR(MAX) NULL,
    [OfferDetails] NVARCHAR(MAX) NULL,
    [isActive] BIT NOT NULL DEFAULT 1,
    PRIMARY KEY ([ApplicationID]),
    CONSTRAINT [UQ_Application_JobSeeker_Job] UNIQUE ([JobSeekerID], [JobID]),
    CONSTRAINT [FK_Application_JobSeekerID_JobSeeker]
        FOREIGN KEY ([JobSeekerID]) REFERENCES [JobSeeker]([JobSeekerID])
        ON UPDATE NO ACTION  
        ON DELETE CASCADE,
    CONSTRAINT [FK_Application_JobID_Job]
        FOREIGN KEY ([JobID]) REFERENCES [Job]([JobID])
        ON UPDATE NO ACTION  
        ON DELETE NO ACTION,
    CONSTRAINT [CK_Application_InterviewDate] CHECK ([InterviewDate] IS NULL OR [InterviewDate] >= [ApplicationDate]),
    CONSTRAINT [CK_App_Status] CHECK ([ApplicationStatus] IN (N'Submitted',N'UnderReview',N'Shortlisted',N'Interview',N'Offered',N'Rejected',N'Withdrawn'))
);
GO
CREATE INDEX [IX_Application_JobID] ON [Application]([JobID]);
GO

CREATE TABLE [ReviewCompany] (
    [ReviewID] INT NOT NULL IDENTITY(1,1),
    [JobSeekerID] NVARCHAR(128) NOT NULL,
    [CompanyID] NVARCHAR(128) NOT NULL,
    [ReviewTitle] NVARCHAR(255) NULL,
    [ReviewDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [ReviewText] NVARCHAR(MAX) NULL,
    [Rating] TINYINT NOT NULL,
    [VerificationStatus] NVARCHAR(10) NOT NULL DEFAULT N'Pending',
    [IsAnonymous] BIT NOT NULL DEFAULT 1,
    PRIMARY KEY ([ReviewID]),
    CONSTRAINT [UQ_Review_JobSeeker_Company] UNIQUE ([JobSeekerID], [CompanyID]),
    CONSTRAINT [FK_ReviewCompany_JobSeekerID_JobSeeker]
        FOREIGN KEY ([JobSeekerID]) REFERENCES [JobSeeker]([JobSeekerID])
        ON UPDATE NO ACTION 
        ON DELETE CASCADE,
    CONSTRAINT [FK_ReviewCompany_CompanyID_Company]
        FOREIGN KEY ([CompanyID]) REFERENCES [Company]([CompanyID])
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT [CK_ReviewCompany_Rating] CHECK ([Rating] >= 1 AND [Rating] <= 5),
    CONSTRAINT [CK_Review_VerStatus] CHECK ([VerificationStatus] IN (N'Pending',N'Verified',N'Rejected'))
);
GO
CREATE INDEX [IX_ReviewCompany_CompanyID] ON [ReviewCompany]([CompanyID]);
GO

CREATE TABLE [JobMetrics] (
    [JobMetricID] NVARCHAR(128) NOT NULL,
    [AppliedCount] INT NOT NULL DEFAULT 0,
    [LikeCount] INT NOT NULL DEFAULT 0,
    [ViewCount] INT NOT NULL DEFAULT 0,
    [LastUpdated] DATETIME2 NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY ([JobMetricID]),
    CONSTRAINT [FK_JobMetrics_JobMetricID_Job]
        FOREIGN KEY ([JobMetricID]) REFERENCES [Job]([JobID])
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);
GO

CREATE TABLE [Notification] (
    [NotificationID] INT NOT NULL IDENTITY(1,1),
    [NotificationType] NVARCHAR(12) NOT NULL,
    [NotificationContent] NVARCHAR(MAX) NOT NULL,
    [SendDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [ReadStatus] BIT NOT NULL DEFAULT 0,
    [DeliveryMethod] NVARCHAR(10) NULL DEFAULT N'InApp',
    PRIMARY KEY ([NotificationID]),
    CONSTRAINT [CK_Notif_Type] CHECK ([NotificationType] IN (N'Application',N'Interview',N'Offer',N'Rejection',N'Message',N'System')),
    CONSTRAINT [CK_Notif_Delivery] CHECK ([DeliveryMethod] IN (N'Email',N'SMS',N'InApp',N'Push'))
);
GO
CREATE INDEX [IX_Notification_SendDate] ON [Notification]([SendDate]);
GO

CREATE TABLE [ReceiveNotification] (
    [NotificationID] INT NOT NULL,
    [ReceiverID] NVARCHAR(128) NOT NULL,
    PRIMARY KEY ([NotificationID], [ReceiverID]),
    CONSTRAINT [FK_ReceiveNotification_NotificationID_Notification]
        FOREIGN KEY ([NotificationID]) REFERENCES [Notification]([NotificationID])
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT [FK_ReceiveNotification_ReceiverID_User]
        FOREIGN KEY ([ReceiverID]) REFERENCES [User]([UserId])
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);
GO
CREATE INDEX [IX_ReceiveNotification_ReceiverID] ON [ReceiveNotification]([ReceiverID]);
GO

CREATE TABLE [Follow] (
    [FollowerID] NVARCHAR(128) NOT NULL,
    [FolloweeID] NVARCHAR(128) NOT NULL,
    [FollowDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY ([FollowerID], [FolloweeID]),
    CONSTRAINT [FK_Follow_FollowerID_User]
        FOREIGN KEY ([FollowerID]) REFERENCES [User]([UserId])
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT [FK_Follow_FolloweeID_User]
        FOREIGN KEY ([FolloweeID]) REFERENCES [User]([UserId])
        ON UPDATE NO ACTION 
        ON DELETE NO ACTION
);
GO
CREATE INDEX [IX_Follow_FolloweeID] ON [Follow]([FolloweeID]);
GO

CREATE TABLE [SocialProfile] (
    [OwnerId] NVARCHAR(128) NOT NULL,
    [ProfileType] NVARCHAR(10) NOT NULL,
    [URL] NVARCHAR(600) NOT NULL,
    PRIMARY KEY ([OwnerId], [ProfileType]),
    CONSTRAINT [FK_SocialProfile_OwnerId_User]
        FOREIGN KEY ([OwnerId]) REFERENCES [User]([UserId])
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT [CK_Social_Type] CHECK ([ProfileType] IN (N'LinkedIn',N'GitHub',N'Facebook',N'Twitter',N'Portfolio',N'Other'))
);
GO

CREATE TABLE [AuditLog] (
    [LogID] INT NOT NULL IDENTITY(1,1),
    [ActorID] NVARCHAR(128) NULL,
    [ActionType] NVARCHAR(120) NOT NULL,
    [Timestamp] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [Detailed] NVARCHAR(MAX) NULL,
    [IPAddress] VARCHAR(45) NULL,
    PRIMARY KEY ([LogID]),
    CONSTRAINT [FK_AuditLog_ActorID_User]
        FOREIGN KEY ([ActorID]) REFERENCES [User]([UserId])
        ON UPDATE CASCADE 
        ON DELETE SET NULL
);
GO
CREATE INDEX [IX_AuditLog_ActorID_Timestamp] ON [AuditLog]([ActorID], [Timestamp]);
GO

CREATE TABLE [DepartmentContact] (
    [ContactID] INT NOT NULL IDENTITY(1,1),
    [CompanyID] NVARCHAR(128) NOT NULL,
    [ContactEmail] NVARCHAR(256) NOT NULL,
    [ContactName] NVARCHAR(120) NOT NULL,
    [ContactPhone] NVARCHAR(40) NULL,
    [ContactRole] NVARCHAR(120) NULL,
    [Department] NVARCHAR(120) NULL,
    PRIMARY KEY ([ContactID]),
    CONSTRAINT [UQ_DepartmentContact_Email] UNIQUE ([CompanyID], [ContactEmail]),
    CONSTRAINT [FK_DepartmentContact_CompanyID_Company]
        FOREIGN KEY ([CompanyID]) REFERENCES [Company]([CompanyID])
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);
GO

-- =============================================
-- FUNCTIONS (Create before triggers that use them)
-- =============================================

-- Function: Calculate job match score for a job seeker
CREATE FUNCTION dbo.fn_CalculateJobMatchScore(
    @p_JobSeekerID NVARCHAR(128),
    @p_JobID NVARCHAR(128)
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @v_TotalRequiredSkills INT = 0;
    DECLARE @v_MatchedSkills INT = 0;
    DECLARE @v_MatchScore DECIMAL(5,2) = 0;
    
    IF @p_JobSeekerID IS NULL OR @p_JobID IS NULL
    BEGIN
        RETURN 0;
    END
    
    SELECT @v_TotalRequiredSkills = COUNT(*)
    FROM [JobRequireSkill]
    WHERE [JobID] = @p_JobID AND [IsRequired] = 1;
    
    IF @v_TotalRequiredSkills = 0
    BEGIN
        RETURN 0;
    END
    
    SELECT @v_MatchedSkills = COUNT(*)
    FROM [JobRequireSkill] jrs
    INNER JOIN [JobSeekerSkill] jss 
        ON jrs.[SkillID] = jss.[SkillID]
    WHERE jrs.[JobID] = @p_JobID 
        AND jss.[JobSeekerID] = @p_JobSeekerID
        AND jrs.[IsRequired] = 1
        AND (
            (jrs.[ProficiencyLevel] = N'Beginner') OR
            (jrs.[ProficiencyLevel] = N'Intermediate' AND jss.[ProficiencyLevel] IN (N'Intermediate', N'Advanced', N'Expert')) OR
            (jrs.[ProficiencyLevel] = N'Advanced' AND jss.[ProficiencyLevel] IN (N'Advanced', N'Expert')) OR
            (jrs.[ProficiencyLevel] = N'Expert' AND jss.[ProficiencyLevel] = N'Expert')
        );
    
    IF @v_TotalRequiredSkills > 0
        SET @v_MatchScore = (CAST(@v_MatchedSkills AS DECIMAL(10,2)) / @v_TotalRequiredSkills) * 100;
    ELSE
        SET @v_MatchScore = 0;
    
    RETURN @v_MatchScore;
END
GO

-- Function: Get average rating for a company
CREATE FUNCTION dbo.fn_GetCompanyAverageRating(
    @p_CompanyID NVARCHAR(128)
)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @v_AvgRating DECIMAL(3,2) = 0;
    
    IF @p_CompanyID IS NULL OR @p_CompanyID = ''
    BEGIN
        RETURN 0;
    END
    
    SELECT @v_AvgRating = ISNULL(AVG(CAST([Rating] AS DECIMAL(3,2))), 0)
    FROM [ReviewCompany]
    WHERE [CompanyID] = @p_CompanyID 
        AND [VerificationStatus] = N'Verified';
    
    RETURN @v_AvgRating;
END
GO

-- =============================================
-- STORED PROCEDURES (Create before triggers that use them)
-- =============================================

-- Procedure: Update skill popularity scores
CREATE PROCEDURE dbo.sp_UpdateSkillPopularityScores(
    @p_SkillID INT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @v_JobRequireCount INT = 0;
    DECLARE @v_TotalOpenJobs INT = 1;
    DECLARE @v_PopularityScore INT = 0;
    
    IF @p_SkillID IS NULL
    BEGIN
        RAISERROR(N'SkillID cannot be null', 16, 1);
        RETURN;
    END

    SELECT @v_JobRequireCount = COUNT(*)
    FROM [JobRequireSkill] jrs
    INNER JOIN [Job] j ON jrs.[JobID] = j.[JobID]
    WHERE jrs.[SkillID] = @p_SkillID
        AND j.[JobStatus] = N'Open';
    
    SELECT @v_TotalOpenJobs = COUNT(*)
    FROM [Job]
    WHERE [JobStatus] = N'Open';

    IF @v_TotalOpenJobs > 0
    BEGIN
        SET @v_PopularityScore = FLOOR((CAST(@v_JobRequireCount AS DECIMAL(10,2)) / @v_TotalOpenJobs) * 100);
    END
    ELSE
    BEGIN
        SET @v_PopularityScore = 0;
    END

    UPDATE [Skill]
    SET [PopularityScore] = @v_PopularityScore
    WHERE [SkillID] = @p_SkillID;
END
GO

-- Procedure: Get top matching jobs for a job seeker
CREATE PROCEDURE dbo.sp_GetTopMatchingJobs(
    @p_JobSeekerID NVARCHAR(128),
    @p_MinMatchScore DECIMAL(5,2) = 0,
    @p_Limit INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_JobSeekerID IS NULL OR @p_JobSeekerID = ''
    BEGIN
        RAISERROR(N'JobSeekerID cannot be null or empty', 16, 1);
        RETURN;
    END

    IF @p_MinMatchScore < 0 OR @p_MinMatchScore > 100
    BEGIN
        RAISERROR(N'MinMatchScore must be between 0 and 100', 16, 1);
        RETURN;
    END

    IF @p_Limit <= 0
    BEGIN
        SET @p_Limit = 10;
    END

    CREATE TABLE #TempJobMatches (
        [JobID] NVARCHAR(128) NOT NULL,
        [MatchScore] DECIMAL(5,2) NOT NULL,
        PRIMARY KEY ([JobID])
    );
    CREATE INDEX [idx_MatchScore] ON #TempJobMatches ([MatchScore] DESC);

    INSERT INTO #TempJobMatches ([JobID], [MatchScore])
    SELECT 
        j.[JobID],
        dbo.fn_CalculateJobMatchScore(@p_JobSeekerID, j.[JobID]) AS MatchScore
    FROM [Job] j
    WHERE j.[JobStatus] = N'Open'
        AND (j.[ApplicationDeadline] IS NULL OR j.[ApplicationDeadline] > GETDATE())
        AND j.[JobID] NOT IN (
            SELECT [JobID]
            FROM [Application]
            WHERE [JobSeekerID] = @p_JobSeekerID
        );
        
    SELECT TOP (@p_Limit)
        j.[JobID],
        j.[JobTitle],
        c.[CompanyName],
        j.[Location],
        j.[EmploymentType],
        j.[SalaryMin],
        j.[SalaryMax],
        j.[ExperienceRequired],
        j.[PostedDate],
        j.[ApplicationDeadline],
        tjm.[MatchScore]
    FROM #TempJobMatches tjm
    INNER JOIN [Job] j ON tjm.[JobID] = j.[JobID]
    INNER JOIN [Company] c ON j.[CompanyID] = c.[CompanyID]
    WHERE tjm.[MatchScore] >= @p_MinMatchScore
    ORDER BY tjm.[MatchScore] DESC;

    DROP TABLE IF EXISTS #TempJobMatches;
END
GO

-- Procedure: Get application statistics by company
CREATE PROCEDURE dbo.sp_GetApplicationStatisticsByCompany(
    @p_StartDate DATETIME2 = NULL,
    @p_EndDate DATETIME2 = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_StartDate IS NULL
    BEGIN
        SET @p_StartDate = DATEADD(MONTH, -6, GETDATE());
    END

    IF @p_EndDate IS NULL
    BEGIN
        SET @p_EndDate = GETDATE();
    END

    IF @p_EndDate < @p_StartDate
    BEGIN
        RAISERROR(N'EndDate must be greater than or equal to StartDate', 16, 1);
        RETURN;
    END

    ;WITH CompanyStats AS (
        SELECT 
            c.[CompanyID],
            c.[CompanyName],
            c.[Industry],
            c.[CompanySize],
            COUNT(DISTINCT j.[JobID]) AS TotalJobPosted,
            COUNT(a.[ApplicationID]) AS TotalApplications,
            COUNT(CASE WHEN a.[ApplicationStatus] = N'Submitted' THEN 1 END) AS SubmittedCount,
            COUNT(CASE WHEN a.[ApplicationStatus] = N'UnderReview' THEN 1 END) AS UnderReviewCount,
            COUNT(CASE WHEN a.[ApplicationStatus] = N'Interview' THEN 1 END) AS InterviewCount,
            COUNT(CASE WHEN a.[ApplicationStatus] = N'Offered' THEN 1 END) AS OfferedCount,
            COUNT(CASE WHEN a.[ApplicationStatus] = N'Rejected' THEN 1 END) AS RejectedCount,
            ROUND(AVG(CASE 
                WHEN a.[ApplicationStatus] = N'Offered' THEN 100.0
                WHEN a.[ApplicationStatus] = N'Interview' THEN 75.0
                WHEN a.[ApplicationStatus] = N'UnderReview' THEN 50.0
                WHEN a.[ApplicationStatus] = N'Submitted' THEN 25.0
                ELSE 0.0
            END), 2) AS AvgApplicationProgress,
            dbo.fn_GetCompanyAverageRating(c.[CompanyID]) AS CompanyRating
        FROM [Company] c 
        INNER JOIN [Job] j ON c.[CompanyID] = j.[CompanyID]
        LEFT JOIN [Application] a ON j.[JobID] = a.[JobID]
                 AND a.[ApplicationDate] BETWEEN @p_StartDate AND @p_EndDate
        WHERE c.[VerificationStatus] = N'ACCEPTED'
        GROUP BY c.[CompanyID], c.[CompanyName], c.[Industry], c.[CompanySize]
    )
    SELECT * 
    FROM CompanyStats
    WHERE TotalApplications > 0
    ORDER BY TotalApplications DESC, CompanyRating DESC;
END
GO

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger: Update LastLoginDate on User update
CREATE TRIGGER [trg_User_OnUpdate_SetLastLoginDate]
ON [User]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(LastLoginDate)
        RETURN;
    
    UPDATE u
    SET LastLoginDate = GETDATE()
    FROM [User] u
    INNER JOIN inserted i ON u.UserId = i.UserId;
END
GO

-- Trigger: Update LastUpdated on JobMetrics update
CREATE TRIGGER [trg_JobMetrics_OnUpdate_SetLastUpdated]
ON [JobMetrics]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(LastUpdated)
        RETURN;
    
    UPDATE jm
    SET LastUpdated = GETDATE()
    FROM [JobMetrics] jm
    INNER JOIN inserted i ON jm.JobMetricID = i.JobMetricID;
END
GO

-- Trigger: Auto-generate UserId before insert
CREATE TRIGGER [trg_User_BeforeInsert]
ON [User]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @next_id INT;
    DECLARE @new_UserId NVARCHAR(128);
    
    DECLARE @Email NVARCHAR(256), @PasswordHash NVARCHAR(256), @RegistrationDate DATETIME2, 
            @LastLoginDate DATETIME2, @AccountStatus NVARCHAR(10), @UserType NVARCHAR(10);

    DECLARE cursor_inserted CURSOR FOR
    SELECT Email, PasswordHash, ISNULL(RegistrationDate, GETDATE()), 
           ISNULL(LastLoginDate, GETDATE()), ISNULL(AccountStatus, N'Active'), UserType
    FROM inserted;

    OPEN cursor_inserted;
    FETCH NEXT FROM cursor_inserted INTO @Email, @PasswordHash, @RegistrationDate, @LastLoginDate, @AccountStatus, @UserType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(UserId, 3, LEN(UserId)) AS INT)), 0) + 1
        FROM [User] WITH (UPDLOCK, HOLDLOCK)
        WHERE UserId LIKE N'US[0-9]%' AND LEN(UserId) = 9;
        
        SET @new_UserId = CONCAT(N'US', RIGHT(N'0000000' + CAST(@next_id AS NVARCHAR(7)), 7));

        INSERT INTO [User] (
            [UserId], [Email], [PasswordHash], [RegistrationDate], [LastLoginDate], [AccountStatus], [UserType]
        ) VALUES (
            @new_UserId, @Email, @PasswordHash, @RegistrationDate, @LastLoginDate, @AccountStatus, @UserType
        );

        FETCH NEXT FROM cursor_inserted INTO @Email, @PasswordHash, @RegistrationDate, @LastLoginDate, @AccountStatus, @UserType;
    END

    CLOSE cursor_inserted;
    DEALLOCATE cursor_inserted;
END
GO

-- Trigger: Auto-generate JobID before insert
CREATE TRIGGER [trg_Job_BeforeInsert]
ON [Job]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @JobData TABLE (
        [CompanyID] NVARCHAR(128), [JobTitle] NVARCHAR(255), [JobDescription] NVARCHAR(MAX),
        [EmploymentType] NVARCHAR(10), [ExperienceRequired] SMALLINT, [SalaryMin] DECIMAL(15,2),
        [SalaryMax] DECIMAL(15,2), [Location] NVARCHAR(255), [OpeningCount] INT,
        [PostedDate] DATETIME2, [ApplicationDeadline] DATETIME2, [JobStatus] NVARCHAR(10)
    );

    INSERT INTO @JobData
    SELECT
        [CompanyID], [JobTitle], [JobDescription], [EmploymentType],
        ISNULL([ExperienceRequired], 0), [SalaryMin], [SalaryMax], [Location],
        ISNULL([OpeningCount], 1), ISNULL([PostedDate], GETDATE()), 
        [ApplicationDeadline], ISNULL([JobStatus], N'Open')
    FROM inserted;

    DECLARE @CompanyID NVARCHAR(128), @JobTitle NVARCHAR(255), @JobDescription NVARCHAR(MAX),
            @EmploymentType NVARCHAR(10), @ExperienceRequired SMALLINT, @SalaryMin DECIMAL(15,2),
            @SalaryMax DECIMAL(15,2), @Location NVARCHAR(255), @OpeningCount INT,
            @PostedDate DATETIME2, @ApplicationDeadline DATETIME2, @JobStatus NVARCHAR(10);
    
    DECLARE @next_id INT;
    DECLARE @new_JobID NVARCHAR(128);

    DECLARE job_cursor CURSOR FOR
    SELECT * FROM @JobData;

    OPEN job_cursor;
    FETCH NEXT FROM job_cursor INTO @CompanyID, @JobTitle, @JobDescription, @EmploymentType, 
        @ExperienceRequired, @SalaryMin, @SalaryMax, @Location, @OpeningCount, 
        @PostedDate, @ApplicationDeadline, @JobStatus;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(JobID, 4, LEN(JobID)) AS INT)), 0) + 1
        FROM [Job] WITH (UPDLOCK, HOLDLOCK)
        WHERE JobID LIKE N'JOB[0-9]%' AND LEN(JobID) = 10;
        
        SET @new_JobID = CONCAT(N'JOB', RIGHT(N'0000000' + CAST(@next_id AS NVARCHAR(7)), 7));

        INSERT INTO [Job] (
            [JobID], [CompanyID], [JobTitle], [JobDescription], [EmploymentType], 
            [ExperienceRequired], [SalaryMin], [SalaryMax], [Location], [OpeningCount], 
            [PostedDate], [ApplicationDeadline], [JobStatus]
        ) VALUES (
            @new_JobID, @CompanyID, @JobTitle, @JobDescription, @EmploymentType, 
            @ExperienceRequired, @SalaryMin, @SalaryMax, @Location, @OpeningCount, 
            @PostedDate, @ApplicationDeadline, @JobStatus
        );

        FETCH NEXT FROM job_cursor INTO @CompanyID, @JobTitle, @JobDescription, @EmploymentType, 
            @ExperienceRequired, @SalaryMin, @SalaryMax, @Location, @OpeningCount, 
            @PostedDate, @ApplicationDeadline, @JobStatus;
    END

    CLOSE job_cursor;
    DEALLOCATE job_cursor;
END
GO

-- Trigger: Validate FounderYear on Company insert
CREATE TRIGGER [trg_Company_BeforeInsert]
ON [Company]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE FounderYear IS NOT NULL AND FounderYear > YEAR(GETDATE()))
    BEGIN
        RAISERROR(N'FounderYear cannot be in the future', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- Trigger: Validate FounderYear on Company update
CREATE TRIGGER [trg_Company_BeforeUpdate]
ON [Company]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE FounderYear IS NOT NULL AND FounderYear > YEAR(GETDATE()))
    BEGIN
        RAISERROR(N'FounderYear cannot be in the future', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- Trigger: Update skill popularity after JobRequireSkill insert
CREATE TRIGGER [trg_JobRequireSkill_AfterInsert]
ON [JobRequireSkill]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AffectedSkills TABLE (SkillID INT);
    
    INSERT INTO @AffectedSkills (SkillID)
    SELECT DISTINCT i.SkillID
    FROM inserted i
    INNER JOIN [Job] j ON i.JobID = j.JobID
    WHERE j.JobStatus = N'Open';

    DECLARE @SkillID INT;
    DECLARE skill_cursor CURSOR FOR
    SELECT SkillID FROM @AffectedSkills;

    OPEN skill_cursor;
    FETCH NEXT FROM skill_cursor INTO @SkillID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_UpdateSkillPopularityScores @p_SkillID = @SkillID;
        FETCH NEXT FROM skill_cursor INTO @SkillID;
    END

    CLOSE skill_cursor;
    DEALLOCATE skill_cursor;
END
GO

-- Trigger: Update skill popularity after JobRequireSkill delete
CREATE TRIGGER [trg_JobRequireSkill_AfterDelete]
ON [JobRequireSkill]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @AffectedSkills TABLE (SkillID INT PRIMARY KEY);
    
    INSERT INTO @AffectedSkills (SkillID)
    SELECT DISTINCT SkillID FROM deleted;

    DECLARE @SkillID INT;
    DECLARE skill_cursor CURSOR FOR
    SELECT SkillID FROM @AffectedSkills;

    OPEN skill_cursor;
    FETCH NEXT FROM skill_cursor INTO @SkillID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_UpdateSkillPopularityScores @p_SkillID = @SkillID;
        FETCH NEXT FROM skill_cursor INTO @SkillID;
    END

    CLOSE skill_cursor;
    DEALLOCATE skill_cursor;
END
GO

-- Trigger: Check job status and deadline before application insert
CREATE TRIGGER [trg_Application_BeforeInsert_CheckDeadline]
ON [Application]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if job is open
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN [Job] j ON i.[JobID] = j.[JobID]
        WHERE j.[JobStatus] != N'Open'
    )
    BEGIN
        RAISERROR(N'Cannot apply to a job that is not open', 16, 1);
        RETURN;
    END

    -- Check if deadline has passed
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN [Job] j ON i.[JobID] = j.[JobID]
        WHERE j.[ApplicationDeadline] IS NOT NULL AND j.[ApplicationDeadline] < GETDATE()
    )
    BEGIN
        RAISERROR(N'Cannot apply after the application deadline', 16, 1);
        RETURN;
    END

    -- If all checks pass, insert the data
    INSERT INTO [Application] (
        [JobSeekerID], [JobID], [ApplicationDate], [CoverLetterURL], [InterviewDate],
        [InterviewNote], [ApplicationStatus], [RejectedReason], [OfferDetails], [isActive]
    )
    SELECT 
        [JobSeekerID], [JobID], ISNULL([ApplicationDate], GETDATE()), [CoverLetterURL], 
        [InterviewDate], [InterviewNote], ISNULL([ApplicationStatus], N'Submitted'), 
        [RejectedReason], [OfferDetails], ISNULL([isActive], 1)
    FROM inserted;
END
GO

-- Trigger: Validate DateOfBirth on JobSeeker insert
CREATE TRIGGER [trg_JobSeeker_BeforeInsert]
ON [JobSeeker]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE DateOfBirth IS NOT NULL AND DateOfBirth > GETDATE())
    BEGIN
        RAISERROR(N'DateOfBirth cannot be in the future', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- Trigger: Validate DateOfBirth on JobSeeker update
CREATE TRIGGER [trg_JobSeeker_BeforeUpdate]
ON [JobSeeker]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE DateOfBirth IS NOT NULL AND DateOfBirth > GETDATE())
    BEGIN
        RAISERROR(N'DateOfBirth cannot be in the future', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- Trigger: Prevent self-following on Follow insert
CREATE TRIGGER [trg_check_no_self_follow]
ON [Follow]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE FollowerID = FolloweeID)
    BEGIN
        RAISERROR(N'A user cannot follow themselves', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- Trigger: Prevent self-following on Follow update
CREATE TRIGGER [trg_check_no_self_follow_update]
ON [Follow]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE FollowerID = FolloweeID)
    BEGIN
        RAISERROR(N'A user cannot follow themselves', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- =============================================
-- SUCCESS MESSAGE
-- =============================================

PRINT '';
PRINT '========================================';
PRINT 'Database TechTalentHub created successfully!';
PRINT '========================================';
PRINT '';
PRINT 'Summary:';
PRINT '  - 18 Tables created';
PRINT '  - 2 Functions created';
PRINT '  - 3 Stored Procedures created';
PRINT '  - 13 Triggers created';
PRINT '';
PRINT 'All objects have been created without errors.';
PRINT '';
GO