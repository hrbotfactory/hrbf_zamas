-- CreateTable
CREATE TABLE `EventType` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(191) NOT NULL,
    `slug` VARCHAR(191) NOT NULL,
    `description` VARCHAR(191) NULL,
    `position` INTEGER NOT NULL DEFAULT 0,
    `locations` JSON NULL,
    `length` INTEGER NOT NULL,
    `hidden` BOOLEAN NOT NULL DEFAULT false,
    `userId` INTEGER NULL,
    `teamId` INTEGER NULL,
    `eventName` VARCHAR(191) NULL,
    `timeZone` VARCHAR(191) NULL,
    `periodType` ENUM('unlimited', 'rolling', 'range') NOT NULL DEFAULT 'unlimited',
    `periodStartDate` DATETIME(3) NULL,
    `periodEndDate` DATETIME(3) NULL,
    `periodDays` INTEGER NULL,
    `periodCountCalendarDays` BOOLEAN NULL,
    `requiresConfirmation` BOOLEAN NOT NULL DEFAULT false,
    `recurringEvent` JSON NULL,
    `disableGuests` BOOLEAN NOT NULL DEFAULT false,
    `hideCalendarNotes` BOOLEAN NOT NULL DEFAULT false,
    `minimumBookingNotice` INTEGER NOT NULL DEFAULT 120,
    `beforeEventBuffer` INTEGER NOT NULL DEFAULT 0,
    `afterEventBuffer` INTEGER NOT NULL DEFAULT 0,
    `seatsPerTimeSlot` INTEGER NULL,
    `schedulingType` ENUM('roundRobin', 'collective') NULL,
    `scheduleId` INTEGER NULL,
    `price` INTEGER NOT NULL DEFAULT 0,
    `currency` VARCHAR(191) NOT NULL DEFAULT 'usd',
    `slotInterval` INTEGER NULL,
    `metadata` JSON NULL,
    `successRedirectUrl` VARCHAR(191) NULL,

    UNIQUE INDEX `EventType_userId_slug_key`(`userId`, `slug`),
    UNIQUE INDEX `EventType_teamId_slug_key`(`teamId`, `slug`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Credential` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `type` VARCHAR(191) NOT NULL,
    `key` JSON NOT NULL,
    `userId` INTEGER NULL,
    `appId` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `DestinationCalendar` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `integration` VARCHAR(191) NOT NULL,
    `externalId` VARCHAR(191) NOT NULL,
    `userId` INTEGER NULL,
    `eventTypeId` INTEGER NULL,
    `credentialId` INTEGER NULL,

    UNIQUE INDEX `DestinationCalendar_userId_key`(`userId`),
    UNIQUE INDEX `DestinationCalendar_eventTypeId_key`(`eventTypeId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `users` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(191) NULL,
    `name` VARCHAR(191) NULL,
    `email` VARCHAR(191) NOT NULL,
    `emailVerified` DATETIME(3) NULL,
    `password` VARCHAR(191) NULL,
    `bio` VARCHAR(191) NULL,
    `avatar` VARCHAR(191) NULL,
    `timeZone` VARCHAR(191) NOT NULL DEFAULT 'Europe/London',
    `weekStart` VARCHAR(191) NOT NULL DEFAULT 'Sunday',
    `startTime` INTEGER NOT NULL DEFAULT 0,
    `endTime` INTEGER NOT NULL DEFAULT 1440,
    `bufferTime` INTEGER NOT NULL DEFAULT 0,
    `hideBranding` BOOLEAN NOT NULL DEFAULT false,
    `theme` VARCHAR(191) NULL,
    `created` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `trialEndsAt` DATETIME(3) NULL,
    `defaultScheduleId` INTEGER NULL,
    `completedOnboarding` BOOLEAN NOT NULL DEFAULT false,
    `locale` VARCHAR(191) NULL,
    `timeFormat` INTEGER NULL DEFAULT 12,
    `twoFactorSecret` VARCHAR(191) NULL,
    `twoFactorEnabled` BOOLEAN NOT NULL DEFAULT false,
    `identityProvider` ENUM('CAL', 'GOOGLE', 'SAML') NOT NULL DEFAULT 'CAL',
    `identityProviderId` VARCHAR(191) NULL,
    `invitedTo` INTEGER NULL,
    `plan` ENUM('FREE', 'TRIAL', 'PRO') NOT NULL DEFAULT 'PRO',
    `brandColor` VARCHAR(191) NOT NULL DEFAULT '#292929',
    `darkBrandColor` VARCHAR(191) NOT NULL DEFAULT '#fafafa',
    `away` BOOLEAN NOT NULL DEFAULT false,
    `allowDynamicBooking` BOOLEAN NULL DEFAULT true,
    `metadata` JSON NULL,
    `verified` BOOLEAN NULL DEFAULT false,
    `role` ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER',
    `disableImpersonation` BOOLEAN NOT NULL DEFAULT false,

    UNIQUE INDEX `users_username_key`(`username`),
    UNIQUE INDEX `users_email_key`(`email`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Team` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `slug` VARCHAR(191) NOT NULL,
    `logo` VARCHAR(191) NULL,
    `bio` VARCHAR(191) NULL,
    `hideBranding` BOOLEAN NOT NULL DEFAULT false,

    UNIQUE INDEX `Team_slug_key`(`slug`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Membership` (
    `teamId` INTEGER NOT NULL,
    `userId` INTEGER NOT NULL,
    `accepted` BOOLEAN NOT NULL DEFAULT false,
    `role` ENUM('MEMBER', 'ADMIN', 'OWNER') NOT NULL,
    `disableImpersonation` BOOLEAN NOT NULL DEFAULT false,

    PRIMARY KEY (`userId`, `teamId`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `VerificationToken` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(191) NOT NULL,
    `token` VARCHAR(191) NOT NULL,
    `expires` DATETIME(3) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `VerificationToken_token_key`(`token`),
    UNIQUE INDEX `VerificationToken_identifier_token_key`(`identifier`, `token`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `BookingReference` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `type` VARCHAR(191) NOT NULL,
    `uid` VARCHAR(191) NOT NULL,
    `meetingId` VARCHAR(191) NULL,
    `meetingPassword` VARCHAR(191) NULL,
    `meetingUrl` VARCHAR(191) NULL,
    `bookingId` INTEGER NULL,
    `externalCalendarId` VARCHAR(191) NULL,
    `deleted` BOOLEAN NULL,
    `credentialId` INTEGER NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Attendee` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `email` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `timeZone` VARCHAR(191) NOT NULL,
    `locale` VARCHAR(191) NULL DEFAULT 'en',
    `bookingId` INTEGER NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Booking` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `uid` VARCHAR(191) NOT NULL,
    `userId` INTEGER NULL,
    `eventTypeId` INTEGER NULL,
    `title` VARCHAR(191) NOT NULL,
    `description` VARCHAR(191) NULL,
    `customInputs` JSON NULL,
    `startTime` DATETIME(3) NOT NULL,
    `endTime` DATETIME(3) NOT NULL,
    `location` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NULL,
    `status` ENUM('cancelled', 'accepted', 'rejected', 'pending') NOT NULL DEFAULT 'accepted',
    `paid` BOOLEAN NOT NULL DEFAULT false,
    `destinationCalendarId` INTEGER NULL,
    `cancellationReason` VARCHAR(191) NULL,
    `rejectionReason` VARCHAR(191) NULL,
    `dynamicEventSlugRef` VARCHAR(191) NULL,
    `dynamicGroupSlugRef` VARCHAR(191) NULL,
    `rescheduled` BOOLEAN NULL,
    `fromReschedule` VARCHAR(191) NULL,
    `recurringEventId` VARCHAR(191) NULL,
    `smsReminderNumber` VARCHAR(191) NULL,
    `scheduledJobs` JSON NULL,

    UNIQUE INDEX `Booking_uid_key`(`uid`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Schedule` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `userId` INTEGER NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `timeZone` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Availability` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `userId` INTEGER NULL,
    `eventTypeId` INTEGER NULL,
    `days` JSON NOT NULL,
    `startTime` TIME NOT NULL,
    `endTime` TIME NOT NULL,
    `date` DATE NULL,
    `scheduleId` INTEGER NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `SelectedCalendar` (
    `userId` INTEGER NOT NULL,
    `integration` VARCHAR(191) NOT NULL,
    `externalId` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`userId`, `integration`, `externalId`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `EventTypeCustomInput` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `eventTypeId` INTEGER NOT NULL,
    `label` VARCHAR(191) NOT NULL,
    `type` ENUM('text', 'textLong', 'number', 'bool') NOT NULL,
    `required` BOOLEAN NOT NULL,
    `placeholder` VARCHAR(191) NOT NULL DEFAULT '',

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ResetPasswordRequest` (
    `id` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `expires` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ReminderMail` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `referenceId` INTEGER NOT NULL,
    `reminderType` ENUM('PENDING_BOOKING_CONFIRMATION') NOT NULL,
    `elapsedMinutes` INTEGER NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Payment` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `uid` VARCHAR(191) NOT NULL,
    `type` ENUM('STRIPE') NOT NULL,
    `bookingId` INTEGER NOT NULL,
    `amount` INTEGER NOT NULL,
    `fee` INTEGER NOT NULL,
    `currency` VARCHAR(191) NOT NULL,
    `success` BOOLEAN NOT NULL,
    `refunded` BOOLEAN NOT NULL,
    `data` JSON NOT NULL,
    `externalId` VARCHAR(191) NOT NULL,

    UNIQUE INDEX `Payment_uid_key`(`uid`),
    UNIQUE INDEX `Payment_externalId_key`(`externalId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Webhook` (
    `id` VARCHAR(191) NOT NULL,
    `userId` INTEGER NULL,
    `eventTypeId` INTEGER NULL,
    `subscriberUrl` VARCHAR(191) NOT NULL,
    `payloadTemplate` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `active` BOOLEAN NOT NULL DEFAULT true,
    `eventTriggers` JSON NOT NULL,
    `appId` VARCHAR(191) NULL,
    `secret` VARCHAR(191) NULL,

    UNIQUE INDEX `Webhook_id_key`(`id`),
    UNIQUE INDEX `Webhook_userId_subscriberUrl_key`(`userId`, `subscriberUrl`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Impersonations` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `impersonatedUserId` INTEGER NOT NULL,
    `impersonatedById` INTEGER NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ApiKey` (
    `id` VARCHAR(191) NOT NULL,
    `userId` INTEGER NOT NULL,
    `note` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `expiresAt` DATETIME(3) NULL,
    `lastUsedAt` DATETIME(3) NULL,
    `hashedKey` VARCHAR(191) NOT NULL,
    `appId` VARCHAR(191) NULL,

    UNIQUE INDEX `ApiKey_id_key`(`id`),
    UNIQUE INDEX `ApiKey_hashedKey_key`(`hashedKey`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `HashedLink` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `link` VARCHAR(191) NOT NULL,
    `eventTypeId` INTEGER NOT NULL,

    UNIQUE INDEX `HashedLink_link_key`(`link`),
    UNIQUE INDEX `HashedLink_eventTypeId_key`(`eventTypeId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Account` (
    `id` VARCHAR(191) NOT NULL,
    `userId` INTEGER NOT NULL,
    `type` VARCHAR(191) NOT NULL,
    `provider` VARCHAR(191) NOT NULL,
    `providerAccountId` VARCHAR(191) NOT NULL,
    `refresh_token` TEXT NULL,
    `access_token` TEXT NULL,
    `expires_at` INTEGER NULL,
    `token_type` VARCHAR(191) NULL,
    `scope` VARCHAR(191) NULL,
    `id_token` TEXT NULL,
    `session_state` VARCHAR(191) NULL,

    UNIQUE INDEX `Account_provider_providerAccountId_key`(`provider`, `providerAccountId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Session` (
    `id` VARCHAR(191) NOT NULL,
    `sessionToken` VARCHAR(191) NOT NULL,
    `userId` INTEGER NOT NULL,
    `expires` DATETIME(3) NOT NULL,

    UNIQUE INDEX `Session_sessionToken_key`(`sessionToken`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `App` (
    `slug` VARCHAR(191) NOT NULL,
    `dirName` VARCHAR(191) NOT NULL,
    `keys` JSON NULL,
    `categories` JSON NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `App_slug_key`(`slug`),
    UNIQUE INDEX `App_dirName_key`(`dirName`),
    PRIMARY KEY (`slug`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `App_RoutingForms_Form` (
    `id` VARCHAR(191) NOT NULL,
    `description` VARCHAR(191) NULL,
    `routes` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `fields` JSON NULL,
    `userId` INTEGER NOT NULL,
    `disabled` BOOLEAN NOT NULL DEFAULT false,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `App_RoutingForms_FormResponse` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `formFillerId` VARCHAR(191) NOT NULL,
    `formId` VARCHAR(191) NOT NULL,
    `response` JSON NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `App_RoutingForms_FormResponse_formFillerId_formId_key`(`formFillerId`, `formId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Feedback` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `userId` INTEGER NOT NULL,
    `rating` VARCHAR(191) NOT NULL,
    `comment` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `WorkflowStep` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `stepNumber` INTEGER NOT NULL,
    `action` ENUM('EMAIL_HOST', 'EMAIL_ATTENDEE', 'SMS_ATTENDEE', 'SMS_NUMBER', 'EMAIL_ADDRESS') NOT NULL,
    `workflowId` INTEGER NOT NULL,
    `sendTo` VARCHAR(191) NULL,
    `reminderBody` VARCHAR(191) NULL,
    `emailSubject` VARCHAR(191) NULL,
    `template` ENUM('REMINDER', 'CUSTOM') NOT NULL DEFAULT 'REMINDER',

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Workflow` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `userId` INTEGER NOT NULL,
    `trigger` ENUM('BEFORE_EVENT', 'EVENT_CANCELLED', 'NEW_EVENT', 'AFTER_EVENT', 'RESCHEDULE_EVENT') NOT NULL,
    `time` INTEGER NULL,
    `timeUnit` ENUM('day', 'hour', 'minute') NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `WorkflowsOnEventTypes` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `workflowId` INTEGER NOT NULL,
    `eventTypeId` INTEGER NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `WorkflowReminder` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `bookingUid` VARCHAR(191) NOT NULL,
    `method` ENUM('EMAIL', 'SMS') NOT NULL,
    `scheduledDate` DATETIME(3) NOT NULL,
    `referenceId` VARCHAR(191) NULL,
    `scheduled` BOOLEAN NOT NULL,
    `workflowStepId` INTEGER NOT NULL,

    UNIQUE INDEX `WorkflowReminder_referenceId_key`(`referenceId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `_user_eventtype` (
    `A` INTEGER NOT NULL,
    `B` INTEGER NOT NULL,

    UNIQUE INDEX `_user_eventtype_AB_unique`(`A`, `B`),
    INDEX `_user_eventtype_B_index`(`B`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `EventType` ADD CONSTRAINT `EventType_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `EventType` ADD CONSTRAINT `EventType_teamId_fkey` FOREIGN KEY (`teamId`) REFERENCES `Team`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `EventType` ADD CONSTRAINT `EventType_scheduleId_fkey` FOREIGN KEY (`scheduleId`) REFERENCES `Schedule`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Credential` ADD CONSTRAINT `Credential_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Credential` ADD CONSTRAINT `Credential_appId_fkey` FOREIGN KEY (`appId`) REFERENCES `App`(`slug`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `DestinationCalendar` ADD CONSTRAINT `DestinationCalendar_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `DestinationCalendar` ADD CONSTRAINT `DestinationCalendar_eventTypeId_fkey` FOREIGN KEY (`eventTypeId`) REFERENCES `EventType`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `DestinationCalendar` ADD CONSTRAINT `DestinationCalendar_credentialId_fkey` FOREIGN KEY (`credentialId`) REFERENCES `Credential`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Membership` ADD CONSTRAINT `Membership_teamId_fkey` FOREIGN KEY (`teamId`) REFERENCES `Team`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Membership` ADD CONSTRAINT `Membership_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `BookingReference` ADD CONSTRAINT `BookingReference_bookingId_fkey` FOREIGN KEY (`bookingId`) REFERENCES `Booking`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Attendee` ADD CONSTRAINT `Attendee_bookingId_fkey` FOREIGN KEY (`bookingId`) REFERENCES `Booking`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Booking` ADD CONSTRAINT `Booking_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Booking` ADD CONSTRAINT `Booking_eventTypeId_fkey` FOREIGN KEY (`eventTypeId`) REFERENCES `EventType`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Booking` ADD CONSTRAINT `Booking_destinationCalendarId_fkey` FOREIGN KEY (`destinationCalendarId`) REFERENCES `DestinationCalendar`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Schedule` ADD CONSTRAINT `Schedule_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Availability` ADD CONSTRAINT `Availability_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Availability` ADD CONSTRAINT `Availability_eventTypeId_fkey` FOREIGN KEY (`eventTypeId`) REFERENCES `EventType`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Availability` ADD CONSTRAINT `Availability_scheduleId_fkey` FOREIGN KEY (`scheduleId`) REFERENCES `Schedule`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `SelectedCalendar` ADD CONSTRAINT `SelectedCalendar_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `EventTypeCustomInput` ADD CONSTRAINT `EventTypeCustomInput_eventTypeId_fkey` FOREIGN KEY (`eventTypeId`) REFERENCES `EventType`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Payment` ADD CONSTRAINT `Payment_bookingId_fkey` FOREIGN KEY (`bookingId`) REFERENCES `Booking`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Webhook` ADD CONSTRAINT `Webhook_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Webhook` ADD CONSTRAINT `Webhook_eventTypeId_fkey` FOREIGN KEY (`eventTypeId`) REFERENCES `EventType`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Webhook` ADD CONSTRAINT `Webhook_appId_fkey` FOREIGN KEY (`appId`) REFERENCES `App`(`slug`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Impersonations` ADD CONSTRAINT `Impersonations_impersonatedUserId_fkey` FOREIGN KEY (`impersonatedUserId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Impersonations` ADD CONSTRAINT `Impersonations_impersonatedById_fkey` FOREIGN KEY (`impersonatedById`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ApiKey` ADD CONSTRAINT `ApiKey_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ApiKey` ADD CONSTRAINT `ApiKey_appId_fkey` FOREIGN KEY (`appId`) REFERENCES `App`(`slug`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `HashedLink` ADD CONSTRAINT `HashedLink_eventTypeId_fkey` FOREIGN KEY (`eventTypeId`) REFERENCES `EventType`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Account` ADD CONSTRAINT `Account_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Session` ADD CONSTRAINT `Session_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `App_RoutingForms_Form` ADD CONSTRAINT `App_RoutingForms_Form_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `App_RoutingForms_FormResponse` ADD CONSTRAINT `App_RoutingForms_FormResponse_formId_fkey` FOREIGN KEY (`formId`) REFERENCES `App_RoutingForms_Form`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Feedback` ADD CONSTRAINT `Feedback_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `WorkflowStep` ADD CONSTRAINT `WorkflowStep_workflowId_fkey` FOREIGN KEY (`workflowId`) REFERENCES `Workflow`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Workflow` ADD CONSTRAINT `Workflow_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `WorkflowsOnEventTypes` ADD CONSTRAINT `WorkflowsOnEventTypes_workflowId_fkey` FOREIGN KEY (`workflowId`) REFERENCES `Workflow`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `WorkflowsOnEventTypes` ADD CONSTRAINT `WorkflowsOnEventTypes_eventTypeId_fkey` FOREIGN KEY (`eventTypeId`) REFERENCES `EventType`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `WorkflowReminder` ADD CONSTRAINT `WorkflowReminder_bookingUid_fkey` FOREIGN KEY (`bookingUid`) REFERENCES `Booking`(`uid`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `WorkflowReminder` ADD CONSTRAINT `WorkflowReminder_workflowStepId_fkey` FOREIGN KEY (`workflowStepId`) REFERENCES `WorkflowStep`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `_user_eventtype` ADD CONSTRAINT `_user_eventtype_A_fkey` FOREIGN KEY (`A`) REFERENCES `EventType`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `_user_eventtype` ADD CONSTRAINT `_user_eventtype_B_fkey` FOREIGN KEY (`B`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
