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
    [RegistrationDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [LastLoginDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [AccountStatus] NVARCHAR(10) NOT NULL DEFAULT N'Active',
    [UserType] NVARCHAR(10) NOT NULL,
    [avatarURL] NVARCHAR(512) NOT NULL DEFAULT 'https://aic.com.vn/wp-content/uploads/2024/10/avatar-fb-mac-dinh-1.jpg',
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
    [DateAssigned] DATETIME NOT NULL DEFAULT GETDATE(),
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
    [FoundedYear] SMALLINT NULL,
    [VerificationStatus] NVARCHAR(10) NOT NULL DEFAULT N'PENDING',
    [LogoURL] NVARCHAR(512) NULL,
    [CompanySize] NVARCHAR(10) NULL,
    [Industry] NVARCHAR(128) NULL,
    [CompanyName] NVARCHAR(256) NOT NULL,
    [CompanyDescription] NVARCHAR(MAX) NULL,
    [CompanyWebsite] NVARCHAR(512) NULL,
    PRIMARY KEY ([CompanyID]),
    CONSTRAINT [UQ_Company_CompanyName] UNIQUE ([CompanyName]),
    CONSTRAINT [FK_Company_CompanyID_User]
        FOREIGN KEY ([CompanyID]) REFERENCES [User]([UserId])
        ON UPDATE CASCADE 
        ON DELETE NO ACTION,
    CONSTRAINT [CK_Company_VerificationStatus] CHECK ([VerificationStatus] IN (N'ACCEPTED',N'PENDING',N'REJECTED')),
    CONSTRAINT [CK_Company_CompanySize] CHECK ([CompanySize] IN (N'Small',N'Medium',N'Large',N'Enterprise'))
);
GO


CREATE TABLE [CompanyLocation] (
    [LocationID] INT IDENTITY(1,1) PRIMARY KEY,
    [CompanyID] NVARCHAR(128) NOT NULL,
    [Address] NVARCHAR(300) NOT NULL,  
    CONSTRAINT [UQ_CompanyLocation_CompanyID_Address] UNIQUE ([CompanyID], [Address]),
    CONSTRAINT [FK_CompanyLocation_CompanyID_Company]
        FOREIGN KEY ([CompanyID]) REFERENCES [Company]([CompanyID])
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);
GO

CREATE INDEX [IX_CompanyLocation_CompanyID] ON [CompanyLocation]([CompanyID]);
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
        ON UPDATE NO ACTION 
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
    [PostedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ApplicationDeadline] DATETIME NULL,
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

CREATE TABLE [Application] (
    [ApplicationID] INT NOT NULL IDENTITY(1,1),
    [JobSeekerID] NVARCHAR(128) NOT NULL,
    [JobID] NVARCHAR(128) NOT NULL,
    [ApplicationDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [CoverLetterURL] NVARCHAR(512) NULL,
    [InterviewDate] DATETIME NULL,
    [InterviewNote] NVARCHAR(MAX) NULL,
    [ApplicationStatus] NVARCHAR(12) NOT NULL DEFAULT N'Submitted',
    [RejectedReason] NVARCHAR(MAX) NULL,
    [OfferDetails] NVARCHAR(MAX) NULL,
    [isActive] BIT NOT NULL DEFAULT 1,
    [LastUpdated] DATETIME NOT NULL DEFAULT GETDATE(),
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
    [ReviewDate] DATETIME NOT NULL DEFAULT GETDATE(),
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
    [LastUpdated] DATETIME NOT NULL DEFAULT GETDATE(),
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
    [SendDate] DATETIME NOT NULL DEFAULT GETDATE(),
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
    [FollowDate] DATETIME NOT NULL DEFAULT GETDATE(),
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
    [Timestamp] DATETIME NOT NULL DEFAULT GETDATE(),
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
    CONSTRAINT [UQ_DepartmentContact_Name] UNIQUE ([CompanyID], [ContactName]),
    CONSTRAINT [CK_DepartmentContact_Email] CHECK ([ContactEmail] LIKE N'%@%.%'),
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
    DECLARE @v_MatchedRequiredSkills INT = 0;
    DECLARE @v_TotalOptionalSkills INT = 0;
    DECLARE @v_MatchedOptionalSkills INT = 0;
    DECLARE @v_RequiredScore DECIMAL(10,4) = 0;
    DECLARE @v_OptionalScore DECIMAL(10,4) = 0;
    DECLARE @v_FinalScore DECIMAL(5,2) = 0;
    
    IF @p_JobSeekerID IS NULL OR @p_JobID IS NULL
        RETURN 0;
    
    SELECT @v_TotalRequiredSkills = COUNT(*)
    FROM [JobRequireSkill]
    WHERE [JobID] = @p_JobID AND [IsRequired] = 1;
    
    IF @v_TotalRequiredSkills > 0
    BEGIN
        SELECT @v_MatchedRequiredSkills = COUNT(*)
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
        
        SET @v_RequiredScore = (CAST(@v_MatchedRequiredSkills AS DECIMAL(10,4)) / @v_TotalRequiredSkills) * 70;
    END
    ELSE
    BEGIN
        SET @v_RequiredScore = 70;
    END
    

    SELECT @v_TotalOptionalSkills = COUNT(*)
    FROM [JobRequireSkill]
    WHERE [JobID] = @p_JobID AND [IsRequired] = 0;
    
    IF @v_TotalOptionalSkills > 0
    BEGIN
        SELECT @v_MatchedOptionalSkills = COUNT(*)
        FROM [JobRequireSkill] jrs
        INNER JOIN [JobSeekerSkill] jss 
            ON jrs.[SkillID] = jss.[SkillID]
        WHERE jrs.[JobID] = @p_JobID 
            AND jss.[JobSeekerID] = @p_JobSeekerID
            AND jrs.[IsRequired] = 0
            AND (
                (jrs.[ProficiencyLevel] = N'Beginner') OR
                (jrs.[ProficiencyLevel] = N'Intermediate' AND jss.[ProficiencyLevel] IN (N'Intermediate', N'Advanced', N'Expert')) OR
                (jrs.[ProficiencyLevel] = N'Advanced' AND jss.[ProficiencyLevel] IN (N'Advanced', N'Expert')) OR
                (jrs.[ProficiencyLevel] = N'Expert' AND jss.[ProficiencyLevel] = N'Expert')
            );
        
        DECLARE @v_OptionalMatchRate DECIMAL(10,4) = CAST(@v_MatchedOptionalSkills AS DECIMAL(10,4)) / @v_TotalOptionalSkills;
        
        SET @v_OptionalScore =  @v_OptionalMatchRate * 30;
    END
    ELSE
    BEGIN
        SET @v_OptionalScore = 30;
    END
    
    SET @v_FinalScore = @v_RequiredScore + @v_OptionalScore;
    
    IF @v_FinalScore > 100
        SET @v_FinalScore = 100;
    
    RETURN @v_FinalScore;
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

-- Procedure: Update all skill popularity scores

DROP PROCEDURE IF EXISTS [dbo.sp_UpdateAllSkillPopularityScores];
GO

CREATE PROCEDURE dbo.sp_UpdateAllSkillPopularityScores
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalOpenJobs INT;
    
    SELECT @TotalOpenJobs = COUNT(*)
    FROM [Job]
    WHERE [JobStatus] = N'Open';
    
    IF @TotalOpenJobs = 0
    BEGIN
        UPDATE [Skill] SET [PopularityScore] = 0;
        RETURN;
    END
    

    UPDATE s
    SET s.[PopularityScore] = FLOOR(
        (CAST(ISNULL(job_count.cnt, 0) AS DECIMAL(10,2)) / @TotalOpenJobs) * 100
    )
    FROM [Skill] s
    LEFT JOIN (
        SELECT 
            jrs.SkillID,
            COUNT(DISTINCT jrs.JobID) AS cnt
        FROM [JobRequireSkill] jrs
        INNER JOIN [Job] j ON jrs.JobID = j.JobID
        WHERE j.JobStatus = N'Open'
        GROUP BY jrs.SkillID
    ) job_count ON s.SkillID = job_count.SkillID;
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
        c.[LogoURL],
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

DROP PROCEDURE IF EXISTS [dbo.sp_GetApplicationStatisticsByCompany];
GO

CREATE PROCEDURE dbo.sp_GetApplicationStatisticsByCompany(
    @p_StartDate DATETIME = NULL,
    @p_EndDate DATETIME = NULL
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


DROP TRIGGER IF EXISTS [trg_User_BeforeInsert];
GO

CREATE TRIGGER [trg_User_BeforeInsert]
ON [User]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;

    DECLARE @next_id INT;
    DECLARE @GeneratedIDs TABLE (UserId NVARCHAR(128), Email NVARCHAR(256));
    
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(UserId, 3, LEN(UserId)) AS INT)), 0) + 1
    FROM [User] WITH (TABLOCKX)
    WHERE UserId LIKE N'US[0-9]%' 
      AND LEN(UserId) = 9
      AND ISNUMERIC(SUBSTRING(UserId, 3, LEN(UserId))) = 1;
    
    INSERT INTO [User] (
        [UserId], 
        [Email], 
        [PasswordHash], 
        [RegistrationDate], 
        [LastLoginDate], 
        [AccountStatus], 
        [UserType],
        [avatarURL]
    )
    OUTPUT inserted.UserId, inserted.Email INTO @GeneratedIDs
    SELECT
        CONCAT(N'US', RIGHT(N'0000000' + CAST(
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @next_id - 1 
        AS NVARCHAR(7)), 7)) AS UserId,
        [Email],
        [PasswordHash],
        ISNULL([RegistrationDate], GETDATE()) AS RegistrationDate,
        ISNULL([LastLoginDate], GETDATE()) AS LastLoginDate,
        ISNULL([AccountStatus], N'Active') AS AccountStatus,
        [UserType],
        ISNULL([avatarURL], N'https://aic.com.vn/wp-content/uploads/2024/10/avatar-fb-mac-dinh-1.jpg') AS avatarURL
    FROM inserted;
    
    SELECT UserId, Email FROM @GeneratedIDs;
    
END
GO

-- Trigger: Generate JobID on Job insert

DROP TRIGGER IF EXISTS [trg_Job_BeforeInsert];
GO

CREATE TRIGGER [trg_Job_BeforeInsert]
ON [Job]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;
    
    DECLARE @next_id INT;
    DECLARE @GeneratedIDs TABLE (
        JobID NVARCHAR(128), 
        JobTitle NVARCHAR(255),
        CompanyID NVARCHAR(128)
    );
    
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(JobID, 4, LEN(JobID)) AS INT)), 0) + 1
    FROM [Job] WITH (TABLOCKX)
    WHERE JobID LIKE N'JOB[0-9]%' 
      AND LEN(JobID) = 10
      AND ISNUMERIC(SUBSTRING(JobID, 4, LEN(JobID))) = 1;
    
    INSERT INTO [Job] (
        [JobID], 
        [CompanyID], 
        [JobTitle], 
        [JobDescription], 
        [EmploymentType], 
        [ExperienceRequired], 
        [SalaryMin], 
        [SalaryMax], 
        [Location], 
        [OpeningCount], 
        [PostedDate], 
        [ApplicationDeadline], 
        [JobStatus]
    )
    OUTPUT inserted.JobID, inserted.JobTitle, inserted.CompanyID INTO @GeneratedIDs
    SELECT
        CONCAT(N'JOB', RIGHT(N'0000000' + CAST(
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @next_id - 1 
        AS NVARCHAR(7)), 7)) AS JobID,
        [CompanyID],
        [JobTitle],
        [JobDescription],
        [EmploymentType],
        ISNULL([ExperienceRequired], 0) AS ExperienceRequired,
        [SalaryMin],
        [SalaryMax],
        [Location],
        ISNULL([OpeningCount], 1) AS OpeningCount,
        ISNULL([PostedDate], GETDATE()) AS PostedDate,
        [ApplicationDeadline],
        ISNULL([JobStatus], N'Open') AS JobStatus
    FROM inserted;
    
    SELECT JobID, JobTitle, CompanyID FROM @GeneratedIDs;
END
GO


-- Trigger: Validate FoundedYear on Company insert
CREATE TRIGGER [trg_Company_BeforeInsert]
ON [Company]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE FoundedYear IS NOT NULL AND FoundedYear > YEAR(GETDATE()))
    BEGIN
        RAISERROR(N'FoundedYear cannot be in the future', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- Trigger: Validate FoundedYear on Company update

DROP TRIGGER IF EXISTS [trg_Company_BeforeUpdate];
GO

CREATE TRIGGER [trg_Company_BeforeUpdate]
ON [Company]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE FoundedYear IS NOT NULL AND FoundedYear > YEAR(GETDATE()))
    BEGIN
        RAISERROR(N'FoundedYear cannot be in the future', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- Trigger: Update skill popularity after JobRequireSkill insert

DROP TRIGGER IF EXISTS [trg_JobRequireSkill_AfterInsert];
GO

CREATE TRIGGER [trg_JobRequireSkill_AfterInsert]
ON [JobRequireSkill]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN [Job] j ON i.JobID = j.JobID
        WHERE j.JobStatus = N'Open'
    )
    BEGIN
        EXEC dbo.sp_UpdateAllSkillPopularityScores;
    END
END
GO

-- Trigger: Update skill popularity after JobRequireSkill delete

DROP TRIGGER IF EXISTS [trg_JobRequireSkill_AfterDelete];
GO

CREATE TRIGGER [trg_JobRequireSkill_AfterDelete]
ON [JobRequireSkill]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    

    IF EXISTS (
        SELECT 1 
        FROM deleted d
        INNER JOIN [Job] j ON d.JobID = j.JobID
        WHERE j.JobStatus = N'Open'
    )
    BEGIN
        EXEC dbo.sp_UpdateAllSkillPopularityScores;
    END
END
GO

-- Update popularity scores when job status changes

DROP TRIGGER IF EXISTS [trg_Job_AfterUpdate_JobStatus];
GO

CREATE TRIGGER [trg_Job_AfterUpdate_JobStatus]
ON [Job]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(JobStatus)
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM inserted i
            INNER JOIN deleted d ON i.JobID = d.JobID
            WHERE i.JobStatus != d.JobStatus
              AND (i.JobStatus = N'Open' OR d.JobStatus = N'Open')
        )
        BEGIN
            EXEC dbo.sp_UpdateAllSkillPopularityScores;
        END
    END
END
GO

-- Trigger: Check job status and deadline before application insert

DROP TRIGGER IF EXISTS [trg_Application_BeforeInsert_CheckDeadline];
GO

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

DROP TRIGGER IF EXISTS [trg_JobSeeker_BeforeInsert];
GO
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

DROP TRIGGER IF EXISTS [trg_JobSeeker_BeforeUpdate];
GO

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

DROP TRIGGER IF EXISTS [trg_check_no_self_follow];
GO

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

DROP TRIGGER IF EXISTS [trg_check_no_self_follow_update];
GO

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

-- =========================================
-- INSERT SAMPLE DATA 
-- =========================================

USE [TechTalentHub];
GO
-- =====================================================
-- Sample Data Insertion
-- =====================================================

-- =============================================
-- Insert sample users
-- =============================================

INSERT INTO [User] ([Email], [PasswordHash], [UserType], [AccountStatus], [RegistrationDate]) VALUES
(N'admin@techtalenthub.com', N'$2a$12$yF6QALwl2DVbZ7X1iQiF/ONXNUhBcm2Hj8abEMJvuQqJaFLvF7zxi', N'Admin', N'Active', N'2024-01-15 09:00:00'),
(N'hr@fpt.com.vn', N'$2a$12$3IqAi1nQr6rsSzAO8Tr2YutQIJwDSpKFHl060VGI8FxuO58TLaZAK', N'Company', N'Active', N'2024-02-01 10:30:00'),
(N'recruitment@vng.com.vn', N'$2a$12$3IqAi1nQr6rsSzAO8Tr2YutQIJwDSpKFHl060VGI8FxuO58TLaZAK', N'Company', N'Active', N'2024-02-05 14:20:00'),
(N'talent@techcombank.com.vn', N'$2a$12$3IqAi1nQr6rsSzAO8Tr2YutQIJwDSpKFHl060VGI8FxuO58TLaZAK', N'Company', N'Active', N'2024-02-10 11:15:00'),
(N'hr@viettel.com.vn', N'$2a$12$3IqAi1nQr6rsSzAO8Tr2YutQIJwDSpKFHl060VGI8FxuO58TLaZAK', N'Company', N'Active', N'2024-02-15 16:45:00'),
(N'nguyen.van.a@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-01 08:00:00'),
(N'tran.thi.b@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-05 09:30:00'),
(N'le.van.c@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-10 10:45:00'),
(N'pham.thi.d@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-15 13:20:00'),
(N'hoang.van.e@gmail.com', N'$2a$12$r0864CDy8t8DdL8/dVExpOBvaVDfqP5poySgzvF8dPOUjsUASVBSq', N'JobSeeker', N'Active', N'2024-03-20 15:00:00');
GO


DECLARE @AdminId NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'admin@techtalenthub.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');
DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');

INSERT INTO [Admin] ([AdminId], [AdminName], [AdminRole], [DateAssigned])
SELECT @AdminId, N'System Administrator', N'SuperAdmin', N'2024-01-15 09:00:00';
GO


DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');


-- =============================================
-- Insert sample companies
-- =============================================

INSERT INTO [Company] ([CompanyID], [CompanyName], [FoundedYear], [CompanySize], [Industry], [CompanyDescription], [CompanyWebsite], [VerificationStatus], [LogoURL])
SELECT @CompanyId1, N'FPT Software', 1999, N'Enterprise', N'Information Technology', 
 N'Leading software outsourcing company in Vietnam with over 30,000 employees worldwide. Specializing in digital transformation, AI, cloud computing, and enterprise solutions.',
 N'https://fptsoftware.com', N'ACCEPTED', N'https://cdn.haitrieu.com/wp-content/uploads/2022/01/Logo-FPT.png'
UNION ALL
SELECT @CompanyId2, N'VNG Corporation', 2004, N'Large', N'Technology & Entertainment',
 N'Pioneer in online games, digital content, and e-commerce platforms in Vietnam. Creator of Zalo, Vietnam''s leading messaging app with over 70 million users.',
 N'https://vng.com.vn', N'ACCEPTED', N'https://mondialbrand.com/wp-content/uploads/2024/02/vng_corporation-logo_brandlogos.net_ysr15-1200x1200.png'
UNION ALL
SELECT @CompanyId3, N'Vietnam Technological and Commercial Joint Stock Bank', 1993, N'Large', N'Banking & Finance',
 N'One of the leading commercial banks in Vietnam with cutting-edge fintech solutions. Recognized for innovation in digital banking and customer experience.',
 N'https://techcombank.com.vn', N'ACCEPTED', N'https://cdn.haitrieu.com/wp-content/uploads/2021/11/Logo-TCB-V.png'
UNION ALL
SELECT @CompanyId4, N'Viettel Group', 1989, N'Enterprise', N'Telecommunications',
 N'Largest telecommunications company in Vietnam providing mobile, internet, and digital services. Expanding into AI, IoT, cloud computing, and cybersecurity solutions.',
 N'https://viettel.com.vn', N'ACCEPTED', N'https://media.vneconomy.vn/images/upload/2021/04/20/logo-moi-cua-viettel-1610030805425937362871.jpg?w=600';
GO


DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [CompanyLocation] ([CompanyID], [Address])
SELECT @CompanyId1, N'FPT Building, Tan Thuan EPZ, District 7, HCMC'
UNION ALL SELECT @CompanyId1, N'FPT Tower, Duy Tan Street, Cau Giay, Hanoi'
UNION ALL SELECT @CompanyId2, N'VNG Campus, Z06 Street, Tan Thuan EPZ, District 7, HCMC'
UNION ALL SELECT @CompanyId2, N'VNG Hanoi Office, Keangnam Landmark 72, Pham Hung, Hanoi'
UNION ALL SELECT @CompanyId3, N'Techcombank Tower, 191 Ba Trieu, Hai Ba Trung, Hanoi'
UNION ALL SELECT @CompanyId3, N'162-164 Pasteur, Ben Nghe Ward, District 1, HCMC'
UNION ALL SELECT @CompanyId4, N'Viettel Tower, 285 Cach Mang Thang Tam, District 10, HCMC'
UNION ALL SELECT @CompanyId4, N'Viettel Building, Giang Vo Street, Ba Dinh, Hanoi';
GO

DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');

-- =============================================
-- Insert sample job seekers
-- =============================================


INSERT INTO [JobSeeker] ([JobSeekerID], [FirstName], [LastName], [PhoneNumber], [Gender], [DateOfBirth], [CurrentLocation], [ExperienceLevel], [ProfileSummary], [CVFileURL])
SELECT @JobSeekerId1, N'Van A', N'Nguyen', N'+84901234567', N'MALE', N'1995-05-15', N'Ho Chi Minh City', N'Mid-Level',
 N'Experienced Full-stack Developer with 4+ years building scalable web applications using React, Node.js, and PostgreSQL. Strong problem-solving skills and passion for clean code.',
 N'https://storage.example.com/cv/nguyen-van-a.pdf'
UNION ALL
SELECT @JobSeekerId2, N'Thi B', N'Tran', N'+84912345678', N'FEMALE', N'1998-08-20', N'Hanoi', N'Entry-Level',
 N'Recent graduate with Bachelor degree in Computer Science. Specialized in Data Science and Machine Learning. Completed multiple projects using Python, TensorFlow, and scikit-learn.',
 N'https://storage.example.com/cv/tran-thi-b.pdf'
UNION ALL
SELECT @JobSeekerId3, N'Van C', N'Le', N'+84923456789', N'MALE', N'1992-03-10', N'Da Nang', N'Senior-Level',
 N'Senior Backend Engineer with 7+ years experience in Java, Spring Boot, and microservices architecture. Expert in system design, performance optimization, and leading technical teams.',
 N'https://storage.example.com/cv/le-van-c.pdf'
UNION ALL
SELECT @JobSeekerId4, N'Thi D', N'Pham', N'+84934567890', N'FEMALE', N'1996-11-25', N'Ho Chi Minh City', N'Mid-Level',
 N'DevOps Engineer with 3+ years expertise in AWS, Docker, Kubernetes, and CI/CD automation. Experienced in infrastructure as code using Terraform and building reliable deployment pipelines.',
 N'https://storage.example.com/cv/pham-thi-d.pdf'
UNION ALL
SELECT @JobSeekerId5, N'Van E', N'Hoang', N'+84945678901', N'MALE', N'1994-07-08', N'Hanoi', N'Mid-Level',
 N'Mobile Developer specializing in React Native and Flutter. Built 15+ production mobile apps with 1M+ downloads. Strong focus on UI/UX and app performance optimization.',
 N'https://storage.example.com/cv/hoang-van-e.pdf';
GO

-- =============================================
-- Insert sample skills
-- =============================================


INSERT INTO [Skill] ([SkillName], [SkillCategory], [PopularityScore]) VALUES
(N'Java', N'Programming Language', 0),
(N'Python', N'Programming Language', 0),
(N'JavaScript', N'Programming Language', 0),
(N'React', N'Frontend Framework', 0),
(N'Node.js', N'Backend Framework', 0),
(N'Spring Boot', N'Backend Framework', 0),
(N'MySQL', N'Database', 0),
(N'PostgreSQL', N'Database', 0),
(N'AWS', N'Cloud Platform', 0),
(N'Docker', N'DevOps Tool', 0),
(N'Kubernetes', N'DevOps Tool', 0),
(N'Machine Learning', N'AI/ML', 0),
(N'TensorFlow', N'AI/ML', 0),
(N'React Native', N'Mobile Development', 0),
(N'Flutter', N'Mobile Development', 0);
GO


DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');

INSERT INTO [JobSeekerSkill] ([JobSeekerID], [SkillID], [ProficiencyLevel], [YearOfExperience])
SELECT @JobSeekerId1, 3, N'Expert', 4.0
UNION ALL SELECT @JobSeekerId1, 4, N'Expert', 4.0
UNION ALL SELECT @JobSeekerId1, 5, N'Advanced', 3.5
UNION ALL SELECT @JobSeekerId1, 8, N'Advanced', 3.0
UNION ALL SELECT @JobSeekerId2, 2, N'Advanced', 1.5
UNION ALL SELECT @JobSeekerId2, 12, N'Advanced', 1.0
UNION ALL SELECT @JobSeekerId2, 13, N'Beginner', 1.0
UNION ALL SELECT @JobSeekerId3, 1, N'Expert', 7.0
UNION ALL SELECT @JobSeekerId3, 6, N'Expert', 6.5
UNION ALL SELECT @JobSeekerId3, 7, N'Advanced', 7.0
UNION ALL SELECT @JobSeekerId3, 8, N'Advanced', 5.0
UNION ALL SELECT @JobSeekerId3, 10, N'Advanced', 4.0
UNION ALL SELECT @JobSeekerId4, 9, N'Expert', 3.5
UNION ALL SELECT @JobSeekerId4, 10, N'Expert', 3.5
UNION ALL SELECT @JobSeekerId4, 11, N'Advanced', 2.5
UNION ALL SELECT @JobSeekerId4, 2, N'Advanced', 3.0
UNION ALL SELECT @JobSeekerId5, 3, N'Expert', 4.0
UNION ALL SELECT @JobSeekerId5, 4, N'Advanced', 3.5
UNION ALL SELECT @JobSeekerId5, 14, N'Expert', 3.0
UNION ALL SELECT @JobSeekerId5, 15, N'Intermediate', 1.5;
GO

DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');


-- =============================================
-- Insert sample jobs
-- =============================================

INSERT INTO [Job] ([CompanyID], [JobTitle], [JobDescription], [EmploymentType], [ExperienceRequired], [SalaryMin], [SalaryMax], [Location], [OpeningCount], [ApplicationDeadline], [JobStatus], [PostedDate])
SELECT @CompanyId1, N'Senior Java Developer', 
 N'Join our team to develop enterprise solutions for global clients. You will work on large-scale systems using Java, Spring Boot, and microservices architecture. Requirements: 5+ years Java experience, strong knowledge of design patterns, RESTful APIs, and database optimization.',
 N'FullTime', 5, 2500.00, 4000.00, N'Ho Chi Minh City', 3, N'2025-12-31 23:59:59', N'Open', N'2024-11-01 09:00:00'
UNION ALL
SELECT @CompanyId2, N'Data Scientist', 
 N'Develop machine learning models for gaming analytics and user behavior prediction. Work with big data, Python, TensorFlow, and cloud platforms. Requirements: 2+ years experience in data science, strong statistical knowledge, and passion for gaming industry.',
 N'FullTime', 2, 2000.00, 3500.00, N'Ho Chi Minh City', 2, N'2025-12-31 23:59:59', N'Open', N'2024-11-05 10:00:00'
UNION ALL
SELECT @CompanyId3, N'Full-stack Developer', 
 N'Build and maintain banking applications using React, Node.js, and PostgreSQL. Ensure security, scalability, and excellent user experience. Requirements: 3+ years full-stack experience, knowledge of fintech regulations, and attention to detail.',
 N'FullTime', 3, 2200.00, 3800.00, N'Hanoi', 4, N'2025-12-31 23:59:59', N'Open', N'2024-11-08 11:00:00'
UNION ALL
SELECT @CompanyId4, N'DevOps Engineer', 
 N'Manage cloud infrastructure and implement CI/CD pipelines for telecommunications services. Work with AWS, Docker, Kubernetes, and Terraform. Requirements: 3+ years DevOps experience, AWS certification preferred, strong automation skills.',
 N'FullTime', 3, 2400.00, 4200.00, N'Ho Chi Minh City', 2, N'2026-01-15 23:59:59', N'Open', N'2024-11-10 14:00:00'
UNION ALL
SELECT @CompanyId1, N'Backend Developer (Spring Boot)', 
 N'Build scalable microservices using Spring Boot for international projects. Requirements: 4+ years Java/Spring Boot experience, knowledge of message queues, caching strategies, and API design best practices.',
 N'FullTime', 4, 2300.00, 3800.00, N'Hanoi', 2, N'2026-01-31 23:59:59', N'Open', N'2024-11-12 15:00:00'
UNION ALL
SELECT @CompanyId2, N'Mobile Developer (React Native)', 
 N'Develop cross-platform mobile applications for our digital services. Requirements: 3+ years React Native experience, published apps on App Store/Google Play, strong UI/UX skills, and performance optimization expertise.',
 N'FullTime', 3, 2000.00, 3500.00, N'Ho Chi Minh City', 2, N'2025-12-31 23:59:59', N'Open', N'2024-11-15 16:00:00';
GO


DECLARE @Job1 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Senior Java Developer' ORDER BY PostedDate);
DECLARE @Job2 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Data Scientist' ORDER BY PostedDate);
DECLARE @Job3 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Full-stack Developer' ORDER BY PostedDate);
DECLARE @Job4 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'DevOps Engineer' ORDER BY PostedDate);
DECLARE @Job5 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Backend Developer (Spring Boot)' ORDER BY PostedDate);
DECLARE @Job6 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Mobile Developer (React Native)' ORDER BY PostedDate);

INSERT INTO [JobRequireSkill] ([JobID], [SkillID], [ProficiencyLevel], [IsRequired])
SELECT @Job1, 1, N'Expert', 1
UNION ALL SELECT @Job1, 6, N'Expert', 1
UNION ALL SELECT @Job1, 7, N'Advanced', 1
UNION ALL SELECT @Job1, 10, N'Intermediate', 0
UNION ALL SELECT @Job2, 2, N'Advanced', 1
UNION ALL SELECT @Job2, 12, N'Advanced', 1
UNION ALL SELECT @Job2, 13, N'Intermediate', 1
UNION ALL SELECT @Job2, 8, N'Intermediate', 0
UNION ALL SELECT @Job3, 3, N'Advanced', 1
UNION ALL SELECT @Job3, 4, N'Advanced', 1
UNION ALL SELECT @Job3, 5, N'Advanced', 1
UNION ALL SELECT @Job3, 8, N'Advanced', 1
UNION ALL SELECT @Job3, 10, N'Intermediate', 0
UNION ALL SELECT @Job4, 9, N'Expert', 1
UNION ALL SELECT @Job4, 10, N'Expert', 1
UNION ALL SELECT @Job4, 11, N'Advanced', 1
UNION ALL SELECT @Job4, 2, N'Advanced', 0
UNION ALL SELECT @Job5, 1, N'Expert', 1
UNION ALL SELECT @Job5, 6, N'Expert', 1
UNION ALL SELECT @Job5, 7, N'Advanced', 1
UNION ALL SELECT @Job5, 8, N'Advanced', 0
UNION ALL SELECT @Job5, 10, N'Intermediate', 0
UNION ALL SELECT @Job6, 3, N'Expert', 1
UNION ALL SELECT @Job6, 14, N'Expert', 1
UNION ALL SELECT @Job6, 4, N'Advanced', 0
UNION ALL SELECT @Job6, 15, N'Intermediate', 0;
GO

DECLARE @Job1 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Senior Java Developer' ORDER BY PostedDate);
DECLARE @Job2 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Data Scientist' ORDER BY PostedDate);
DECLARE @Job3 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Full-stack Developer' ORDER BY PostedDate);
DECLARE @Job4 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'DevOps Engineer' ORDER BY PostedDate);
DECLARE @Job5 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Backend Developer (Spring Boot)' ORDER BY PostedDate);
DECLARE @Job6 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Mobile Developer (React Native)' ORDER BY PostedDate);

INSERT INTO [JobMetrics] ([JobMetricID], [AppliedCount], [LikeCount], [ViewCount])
SELECT @Job1, 0, 15, 120
UNION ALL SELECT @Job2, 0, 12, 95
UNION ALL SELECT @Job3, 0, 18, 145
UNION ALL SELECT @Job4, 0, 10, 88
UNION ALL SELECT @Job5, 0, 14, 102
UNION ALL SELECT @Job6, 0, 16, 110;
GO


DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @Job1 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Senior Java Developer' ORDER BY PostedDate);
DECLARE @Job2 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Data Scientist' ORDER BY PostedDate);
DECLARE @Job3 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Full-stack Developer' ORDER BY PostedDate);
DECLARE @Job4 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'DevOps Engineer' ORDER BY PostedDate);
DECLARE @Job5 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Backend Developer (Spring Boot)' ORDER BY PostedDate);
DECLARE @Job6 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Mobile Developer (React Native)' ORDER BY PostedDate);


-- =============================================
-- Insert sample applications
-- =============================================


INSERT INTO [Application] ([JobSeekerID], [JobID], [ApplicationDate], [ApplicationStatus], [CoverLetterURL], [InterviewDate], [InterviewNote])
SELECT @JobSeekerId1, @Job3, N'2024-11-09 10:00:00', N'Interview', N'https://storage.example.com/cover/app001.pdf', 
 N'2024-11-20 14:00:00', N'Strong technical skills, good communication'
UNION ALL
SELECT @JobSeekerId1, @Job6, N'2024-11-16 09:30:00', N'UnderReview', N'https://storage.example.com/cover/app002.pdf', 
 NULL, NULL
UNION ALL
SELECT @JobSeekerId2, @Job2, N'2024-11-06 11:00:00', N'Interview', N'https://storage.example.com/cover/app003.pdf',
 N'2024-11-18 10:00:00', N'Excellent academic background, enthusiastic learner'
UNION ALL
SELECT @JobSeekerId3, @Job1, N'2024-11-02 14:30:00', N'Interview', N'https://storage.example.com/cover/app004.pdf',
 N'2024-11-22 15:00:00', N'Very experienced, strong system design skills'
UNION ALL
SELECT @JobSeekerId3, @Job5, N'2024-11-13 16:00:00', N'Shortlisted', N'https://storage.example.com/cover/app005.pdf',
 NULL, NULL
UNION ALL
SELECT @JobSeekerId4, @Job4, N'2024-11-11 13:00:00', N'Interview', N'https://storage.example.com/cover/app006.pdf',
 N'2024-11-25 11:00:00', N'Strong AWS and Kubernetes experience'
UNION ALL
SELECT @JobSeekerId5, @Job6, N'2024-11-16 10:00:00', N'UnderReview', N'https://storage.example.com/cover/app007.pdf',
 NULL, NULL
UNION ALL
SELECT @JobSeekerId2, @Job3, N'2024-11-14 12:00:00', N'Rejected', N'https://storage.example.com/cover/app008.pdf',
 NULL, N'Insufficient experience in full-stack development';
GO


DECLARE @Job1 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Senior Java Developer' ORDER BY PostedDate);
DECLARE @Job2 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Data Scientist' ORDER BY PostedDate);
DECLARE @Job3 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Full-stack Developer' ORDER BY PostedDate);
DECLARE @Job4 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'DevOps Engineer' ORDER BY PostedDate);
DECLARE @Job5 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Backend Developer (Spring Boot)' ORDER BY PostedDate);
DECLARE @Job6 NVARCHAR(128) = (SELECT TOP 1 JobID FROM [Job] WHERE JobTitle = N'Mobile Developer (React Native)' ORDER BY PostedDate);

UPDATE [JobMetrics]
SET [AppliedCount] = (
    SELECT COUNT(*) FROM [Application] WHERE [JobID] = [JobMetricID]
)
WHERE [JobMetricID] IN (@Job1, @Job2, @Job3, @Job4, @Job5, @Job6);
GO

DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');


-- =============================================
-- Insert sample experiences
-- =============================================


INSERT INTO [Experience] ([JobSeekerID], [CompanyID], [JobTitle], [ExperienceType], [StartDate], [EndDate], [Description])
SELECT @JobSeekerId1, @CompanyId1, N'Full-stack Developer', N'FullTime', N'2020-06-01', N'2024-02-28',
 N'Developed and maintained web applications using React and Node.js. Collaborated with cross-functional teams to deliver high-quality software solutions.'
UNION ALL
SELECT @JobSeekerId1, @CompanyId2, N'Junior Web Developer', N'FullTime', N'2019-03-15', N'2020-05-31',
 N'Built responsive web interfaces and implemented RESTful APIs. Gained experience in Agile development methodology.'
UNION ALL
SELECT @JobSeekerId2, @CompanyId1, N'Data Science Intern', N'Internship', N'2023-06-01', N'2023-12-31',
 N'Analyzed large datasets using Python and machine learning algorithms. Created data visualizations and predictive models for business insights.'
UNION ALL
SELECT @JobSeekerId3, @CompanyId3, N'Senior Backend Engineer', N'FullTime', N'2020-01-01', NULL,
 N'Leading backend development team. Architected microservices infrastructure and mentored junior developers. Implemented CI/CD pipelines and optimized database performance.'
UNION ALL
SELECT @JobSeekerId3, @CompanyId1, N'Backend Developer', N'FullTime', N'2017-07-01', N'2019-12-31',
 N'Developed enterprise Java applications using Spring Boot. Worked on payment processing systems and financial transaction management.'
UNION ALL
SELECT @JobSeekerId3, @CompanyId2, N'Junior Java Developer', N'FullTime', N'2015-09-01', N'2017-06-30',
 N'Built RESTful APIs and integrated third-party services. Learned best practices in software engineering and code quality.'
UNION ALL
SELECT @JobSeekerId4, @CompanyId4, N'DevOps Engineer', N'FullTime', N'2021-03-01', NULL,
 N'Managing AWS infrastructure and implementing automated deployment pipelines. Reduced deployment time by 60% through automation.'
UNION ALL
SELECT @JobSeekerId4, @CompanyId1, N'Junior DevOps Engineer', N'FullTime', N'2019-06-01', N'2021-02-28',
 N'Assisted in cloud migration projects. Implemented monitoring and logging solutions using ELK stack.'
UNION ALL
SELECT @JobSeekerId5, @CompanyId2, N'Mobile Developer', N'FullTime', N'2020-08-01', NULL,
 N'Developing cross-platform mobile applications using React Native and Flutter. Published 10+ apps with excellent user ratings.'
UNION ALL
SELECT @JobSeekerId5, @CompanyId1, N'Mobile Developer Intern', N'Internship', N'2019-06-01', N'2020-07-31',
 N'Learned mobile development fundamentals. Contributed to feature development and bug fixes in production apps.';
GO

DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');


-- =============================================
-- Insert sample reviews
-- =============================================

INSERT INTO [ReviewCompany] ([JobSeekerID], [CompanyID], [ReviewTitle], [ReviewDate], [ReviewText], [Rating], [VerificationStatus], [IsAnonymous])
SELECT @JobSeekerId1, @CompanyId1, N'Great place to grow your career', N'2024-03-15 10:00:00',
 N'FPT Software provides excellent learning opportunities and supportive team environment. Good salary and benefits. Work-life balance could be better during peak project times.',
 4, N'Verified', 0
UNION ALL
SELECT @JobSeekerId1, @CompanyId2, N'Innovative and fun workplace', N'2024-03-20 14:30:00',
 N'VNG has a young, dynamic culture with cutting-edge technology. Great office facilities and team activities. Management is open to new ideas.',
 5, N'Verified', 0
UNION ALL
SELECT @JobSeekerId3, @CompanyId3, N'Excellent fintech company', N'2024-04-10 09:00:00',
 N'Techcombank offers competitive compensation and modern working environment. Challenging projects in banking technology. Great career development opportunities.',
 5, N'Verified', 1
UNION ALL
SELECT @JobSeekerId3, @CompanyId1, N'Good company for Java developers', N'2024-04-15 16:00:00',
 N'Strong technical team with experienced seniors. Good training programs and project exposure. Salary is competitive for the market.',
 4, N'Verified', 1
UNION ALL
SELECT @JobSeekerId4, @CompanyId4, N'Leading telecom with good infrastructure', N'2024-05-01 11:00:00',
 N'Viettel provides stable career path and comprehensive benefits. Good for learning telecom and cloud technologies. Large organization with structured processes.',
 4, N'Verified', 0
UNION ALL
SELECT @JobSeekerId4, @CompanyId1, N'Great for learning DevOps', N'2024-05-10 13:00:00',
 N'FPT has many international projects which provide good exposure. DevOps practices are well-established. Good mentorship from senior engineers.',
 4, N'Verified', 1
UNION ALL
SELECT @JobSeekerId5, @CompanyId2, N'Best place for mobile developers', N'2024-06-01 10:30:00',
 N'VNG invests heavily in mobile technology. You will work on products with millions of users. Great team collaboration and modern tech stack.',
 5, N'Verified', 0;
GO


DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [SocialProfile] ([OwnerId], [ProfileType], [URL])
SELECT @JobSeekerId1, N'LinkedIn', N'https://linkedin.com/in/nguyen-van-a'
UNION ALL SELECT @JobSeekerId1, N'GitHub', N'https://github.com/nguyenvana'
UNION ALL SELECT @JobSeekerId1, N'Portfolio', N'https://nguyenvana.dev'
UNION ALL SELECT @JobSeekerId2, N'LinkedIn', N'https://linkedin.com/in/tran-thi-b'
UNION ALL SELECT @JobSeekerId2, N'GitHub', N'https://github.com/tranthib'
UNION ALL SELECT @JobSeekerId3, N'LinkedIn', N'https://linkedin.com/in/le-van-c'
UNION ALL SELECT @JobSeekerId3, N'GitHub', N'https://github.com/levanc'
UNION ALL SELECT @JobSeekerId3, N'Portfolio', N'https://levanc.tech'
UNION ALL SELECT @JobSeekerId4, N'LinkedIn', N'https://linkedin.com/in/pham-thi-d'
UNION ALL SELECT @JobSeekerId4, N'GitHub', N'https://github.com/phamthid'
UNION ALL SELECT @JobSeekerId5, N'LinkedIn', N'https://linkedin.com/in/hoang-van-e'
UNION ALL SELECT @JobSeekerId5, N'GitHub', N'https://github.com/hoangvane'
UNION ALL SELECT @JobSeekerId5, N'Portfolio', N'https://hoangvane.com'
UNION ALL SELECT @CompanyId1, N'LinkedIn', N'https://linkedin.com/company/fpt-software'
UNION ALL SELECT @CompanyId1, N'Facebook', N'https://www.facebook.com/fptsoftware.official'
UNION ALL SELECT @CompanyId2, N'LinkedIn', N'https://linkedin.com/company/vng-corporation'
UNION ALL SELECT @CompanyId2, N'Facebook', N'https://www.facebook.com/VNGGroup.Official'
UNION ALL SELECT @CompanyId3, N'LinkedIn', N'https://linkedin.com/company/techcombank'
UNION ALL SELECT @CompanyId3, N'Facebook', N'https://facebook.com/techcombank'
UNION ALL SELECT @CompanyId4, N'LinkedIn', N'https://linkedin.com/company/viettel-group'
UNION ALL SELECT @CompanyId4, N'Facebook', N'https://www.facebook.com/vietteltelecom';
GO


DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');

INSERT INTO [Follow] ([FollowerID], [FolloweeID], [FollowDate])
SELECT @JobSeekerId1, @CompanyId1, N'2024-03-02 08:00:00'
UNION ALL SELECT @JobSeekerId1, @CompanyId2, N'2024-03-03 09:00:00'
UNION ALL SELECT @JobSeekerId1, @CompanyId3, N'2024-03-05 10:00:00'
UNION ALL SELECT @JobSeekerId2, @CompanyId1, N'2024-03-06 11:00:00'
UNION ALL SELECT @JobSeekerId2, @CompanyId2, N'2024-03-07 12:00:00'
UNION ALL SELECT @JobSeekerId3, @CompanyId1, N'2024-03-11 08:30:00'
UNION ALL SELECT @JobSeekerId3, @CompanyId3, N'2024-03-12 09:30:00'
UNION ALL SELECT @JobSeekerId3, @CompanyId4, N'2024-03-13 10:30:00'
UNION ALL SELECT @JobSeekerId4, @CompanyId4, N'2024-03-16 11:30:00'
UNION ALL SELECT @JobSeekerId4, @CompanyId1, N'2024-03-17 12:30:00'
UNION ALL SELECT @JobSeekerId5, @CompanyId2, N'2024-03-21 08:45:00'
UNION ALL SELECT @JobSeekerId5, @CompanyId1, N'2024-03-22 09:45:00';
GO


DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');
DECLARE @CompanyId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'talent@techcombank.com.vn');
DECLARE @CompanyId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@viettel.com.vn');


-- =============================================
-- Insert sample department contacts
-- =============================================
INSERT INTO [DepartmentContact] ([CompanyID], [ContactEmail], [ContactName], [ContactPhone], [ContactRole], [Department])
SELECT @CompanyId1, N'hr@fpt.com.vn', N'Nguyen Thi Mai', N'+84281234567', N'HR Manager', N'Human Resources'
UNION ALL SELECT @CompanyId1, N'tech.recruitment@fpt.com.vn', N'Tran Van Hoang', N'+84281234568', N'Technical Recruiter', N'Talent Acquisition'
UNION ALL SELECT @CompanyId1, N'it.support@fpt.com.vn', N'Le Thi Lan', N'+84281234569', N'IT Support Lead', N'Information Technology'
UNION ALL SELECT @CompanyId2, N'recruitment@vng.com.vn', N'Pham Van Duc', N'+84282345678', N'Recruitment Lead', N'Human Resources'
UNION ALL SELECT @CompanyId2, N'tech.hiring@vng.com.vn', N'Hoang Thi Nga', N'+84282345679', N'Tech Talent Partner', N'Engineering'
UNION ALL SELECT @CompanyId3, N'talent@techcombank.com.vn', N'Vu Van Thanh', N'+84243456789', N'Talent Acquisition Manager', N'Human Resources'
UNION ALL SELECT @CompanyId3, N'it.recruitment@techcombank.com.vn', N'Nguyen Thi Huong', N'+84243456790', N'IT Recruiter', N'Technology'
UNION ALL SELECT @CompanyId4, N'hr@viettel.com.vn', N'Dang Van Minh', N'+84284567890', N'HR Director', N'Human Resources'
UNION ALL SELECT @CompanyId4, N'tech.jobs@viettel.com.vn', N'Bui Thi Thao', N'+84284567891', N'Technical Recruiter', N'Technology Division';
GO


INSERT INTO [Notification] ([NotificationType], [NotificationContent], [SendDate], [ReadStatus], [DeliveryMethod])
SELECT N'Application', N'Your application for Senior Java Developer at FPT Software has been received', N'2024-11-02 14:35:00', 1, N'InApp'
UNION ALL SELECT N'Interview', N'You have been scheduled for an interview for Full-stack Developer position at Techcombank', N'2024-11-10 09:00:00', 1, N'Email'
UNION ALL SELECT N'Offer', N'Congratulations! You have received a job offer for Data Scientist position at VNG Corporation', N'2024-11-19 10:00:00', 1, N'Email'
UNION ALL SELECT N'Interview', N'Interview reminder: Your interview for DevOps Engineer at Viettel is tomorrow at 11:00 AM', N'2024-11-24 09:00:00', 0, N'InApp'
UNION ALL SELECT N'Application', N'New application received for Mobile Developer (React Native) position', N'2024-11-16 10:05:00', 1, N'InApp'
UNION ALL SELECT N'System', N'Welcome to TechTalentHub! Complete your profile to get better job recommendations', N'2024-03-01 08:05:00', 1, N'InApp'
UNION ALL SELECT N'System', N'Your company profile has been verified successfully', N'2024-02-02 11:00:00', 1, N'Email'
UNION ALL SELECT N'Message', N'You have a new message from FPT Software HR team', N'2024-11-15 14:30:00', 0, N'InApp';
GO


DECLARE @JobSeekerId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'nguyen.van.a@gmail.com');
DECLARE @JobSeekerId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'tran.thi.b@gmail.com');
DECLARE @JobSeekerId3 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'le.van.c@gmail.com');
DECLARE @JobSeekerId4 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'pham.thi.d@gmail.com');
DECLARE @JobSeekerId5 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hoang.van.e@gmail.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');

INSERT INTO [ReceiveNotification] ([NotificationID], [ReceiverID])
SELECT 1, @JobSeekerId3  -- Application received notification
UNION ALL SELECT 2, @JobSeekerId1  -- Interview schedule notification
UNION ALL SELECT 3, @JobSeekerId2  -- Job offer notification
UNION ALL SELECT 4, @JobSeekerId4  -- Interview reminder notification
UNION ALL SELECT 5, @CompanyId2  -- New application received
UNION ALL SELECT 6, @JobSeekerId1  -- Welcome notification
UNION ALL SELECT 6, @JobSeekerId2
UNION ALL SELECT 6, @JobSeekerId3
UNION ALL SELECT 6, @JobSeekerId4
UNION ALL SELECT 6, @JobSeekerId5
UNION ALL SELECT 7, @CompanyId1  -- Profile verified notification
UNION ALL SELECT 8, @JobSeekerId1;  -- New message notification
GO

DECLARE @AdminId NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'admin@techtalenthub.com');
DECLARE @CompanyId1 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'hr@fpt.com.vn');
DECLARE @CompanyId2 NVARCHAR(128) = (SELECT UserId FROM [User] WHERE Email = N'recruitment@vng.com.vn');

INSERT INTO [AuditLog] ([ActorID], [ActionType], [Timestamp], [Detailed], [IPAddress])
SELECT @AdminId, N'SYSTEM_INIT', N'2024-01-15 09:00:00', N'System initialized and admin account created', N'127.0.0.1'
UNION ALL SELECT @AdminId, N'COMPANY_VERIFICATION', N'2024-02-02 11:00:00', N'Verified company: FPT Software', N'192.168.1.100'
UNION ALL SELECT @AdminId, N'COMPANY_VERIFICATION', N'2024-02-06 10:00:00', N'Verified company: VNG Corporation', N'192.168.1.100'
UNION ALL SELECT @AdminId, N'COMPANY_VERIFICATION', N'2024-02-11 09:00:00', N'Verified company: Techcombank', N'192.168.1.100'
UNION ALL SELECT @AdminId, N'COMPANY_VERIFICATION', N'2024-02-16 14:00:00', N'Verified company: Viettel Group', N'192.168.1.100'
UNION ALL SELECT @CompanyId1, N'JOB_POSTED', N'2024-11-01 09:00:00', N'Posted job: Senior Java Developer', N'118.69.80.123'
UNION ALL SELECT @CompanyId2, N'JOB_POSTED', N'2024-11-05 10:00:00', N'Posted job: Data Scientist', N'118.69.80.124'
UNION ALL SELECT @CompanyId1, N'APPLICATION_REVIEWED', N'2024-11-03 14:00:00', N'Reviewed application from Le Van C', N'118.69.80.123';
GO


SELECT 'Users' AS [Table], COUNT(*) AS [Row Count] FROM [User]
UNION ALL SELECT 'Admins', COUNT(*) FROM [Admin]
UNION ALL SELECT 'Companies', COUNT(*) FROM [Company]
UNION ALL SELECT 'Company Locations', COUNT(*) FROM [CompanyLocation]
UNION ALL SELECT 'Job Seekers', COUNT(*) FROM [JobSeeker]
UNION ALL SELECT 'Skills', COUNT(*) FROM [Skill]
UNION ALL SELECT 'JobSeeker Skills', COUNT(*) FROM [JobSeekerSkill]
UNION ALL SELECT 'Experiences', COUNT(*) FROM [Experience]
UNION ALL SELECT 'Jobs', COUNT(*) FROM [Job]
UNION ALL SELECT 'Job Required Skills', COUNT(*) FROM [JobRequireSkill]
UNION ALL SELECT 'Applications', COUNT(*) FROM [Application]
UNION ALL SELECT 'Company Reviews', COUNT(*) FROM [ReviewCompany]
UNION ALL SELECT 'Job Metrics', COUNT(*) FROM [JobMetrics]
UNION ALL SELECT 'Social Profiles', COUNT(*) FROM [SocialProfile]
UNION ALL SELECT 'Follows', COUNT(*) FROM [Follow]
UNION ALL SELECT 'Department Contacts', COUNT(*) FROM [DepartmentContact]
UNION ALL SELECT 'Notifications', COUNT(*) FROM [Notification]
UNION ALL SELECT 'Receive Notifications', COUNT(*) FROM [ReceiveNotification]
UNION ALL SELECT 'Audit Logs', COUNT(*) FROM [AuditLog]
ORDER BY [Table];

PRINT '';
PRINT 'All sample data has been inserted successfully!';
PRINT 'Database is ready for testing and development.';
PRINT '';
GO


-- =========================================
-- Create a sManager acccount for communicating with database through nodejs
-- =========================================


-- Create a login for sManager at the server level
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'sManager')
BEGIN
    CREATE LOGIN sManager WITH PASSWORD = '123456789';
    PRINT 'Login sManager created successfully.';
END
ELSE
BEGIN
    PRINT 'Login sManager already exists.';
END
GO

USE TechTalentHub;
GO

-- Create a user for sManager in the TechTalentHub database
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'sManager')
BEGIN
    CREATE USER sManager FOR LOGIN sManager;
    PRINT 'User sManager created in TechTalentHub database.';
END
ELSE
BEGIN
    PRINT 'User sManager already exists in TechTalentHub database.';
END
GO

-- Assign db_owner role to sManager user
ALTER ROLE db_owner ADD MEMBER sManager;
PRINT 'User sManager added to db_owner role.';
GO