-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: localhost    Database: evolution
-- ------------------------------------------------------
-- Server version	8.4.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `_prisma_migrations`
--

DROP TABLE IF EXISTS `_prisma_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_prisma_migrations` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `checksum` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `finished_at` datetime(3) DEFAULT NULL,
  `migration_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `logs` text COLLATE utf8mb4_unicode_ci,
  `rolled_back_at` datetime(3) DEFAULT NULL,
  `started_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `applied_steps_count` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chat`
--

DROP TABLE IF EXISTS `chat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remoteJid` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `labels` json DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unreadMessages` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `Chat_instanceId_remoteJid_key` (`instanceId`,`remoteJid`),
  KEY `Chat_instanceId_idx` (`instanceId`),
  KEY `Chat_remoteJid_idx` (`remoteJid`),
  CONSTRAINT `Chat_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chatwoot`
--

DROP TABLE IF EXISTS `chatwoot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chatwoot` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) DEFAULT '1',
  `accountId` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nameInbox` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signMsg` tinyint(1) DEFAULT '0',
  `signDelimiter` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reopenConversation` tinyint(1) DEFAULT '0',
  `conversationPending` tinyint(1) DEFAULT '0',
  `mergeBrazilContacts` tinyint(1) DEFAULT '0',
  `importContacts` tinyint(1) DEFAULT '0',
  `importMessages` tinyint(1) DEFAULT '0',
  `daysLimitImportMessages` int DEFAULT NULL,
  `organization` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ignoreJids` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Chatwoot_instanceId_key` (`instanceId`),
  CONSTRAINT `Chatwoot_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact`
--

DROP TABLE IF EXISTS `contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remoteJid` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pushName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profilePicUrl` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Contact_remoteJid_instanceId_key` (`remoteJid`,`instanceId`),
  KEY `Contact_instanceId_idx` (`instanceId`),
  KEY `Contact_remoteJid_idx` (`remoteJid`),
  CONSTRAINT `Contact_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dify`
--

DROP TABLE IF EXISTS `dify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dify` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `botType` enum('chatBot','textGenerator','agent','workflow') COLLATE utf8mb4_unicode_ci NOT NULL,
  `apiUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiKey` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `triggerType` enum('all','keyword','none','advanced') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerOperator` enum('contains','equals','startsWith','endsWith','regex') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerValue` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  PRIMARY KEY (`id`),
  KEY `Dify_instanceId_fkey` (`instanceId`),
  CONSTRAINT `Dify_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `difysetting`
--

DROP TABLE IF EXISTS `difysetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `difysetting` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `difyIdFallback` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  PRIMARY KEY (`id`),
  UNIQUE KEY `DifySetting_instanceId_key` (`instanceId`),
  KEY `DifySetting_difyIdFallback_fkey` (`difyIdFallback`),
  CONSTRAINT `DifySetting_difyIdFallback_fkey` FOREIGN KEY (`difyIdFallback`) REFERENCES `dify` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `DifySetting_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evoai`
--

DROP TABLE IF EXISTS `evoai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evoai` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `agentUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiKey` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  `triggerType` enum('all','keyword','none','advanced') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerOperator` enum('contains','equals','startsWith','endsWith','regex') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerValue` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Evoai_instanceId_fkey` (`instanceId`),
  CONSTRAINT `Evoai_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evoaisetting`
--

DROP TABLE IF EXISTS `evoaisetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evoaisetting` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `evoaiIdFallback` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `EvoaiSetting_instanceId_key` (`instanceId`),
  KEY `EvoaiSetting_evoaiIdFallback_fkey` (`evoaiIdFallback`),
  CONSTRAINT `EvoaiSetting_evoaiIdFallback_fkey` FOREIGN KEY (`evoaiIdFallback`) REFERENCES `evoai` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `EvoaiSetting_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evolutionbot`
--

DROP TABLE IF EXISTS `evolutionbot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evolutionbot` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiKey` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `triggerType` enum('all','keyword','none','advanced') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerOperator` enum('contains','equals','startsWith','endsWith','regex') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerValue` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  PRIMARY KEY (`id`),
  KEY `EvolutionBot_instanceId_fkey` (`instanceId`),
  CONSTRAINT `EvolutionBot_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evolutionbotsetting`
--

DROP TABLE IF EXISTS `evolutionbotsetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evolutionbotsetting` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `botIdFallback` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  PRIMARY KEY (`id`),
  UNIQUE KEY `EvolutionBotSetting_instanceId_key` (`instanceId`),
  KEY `EvolutionBotSetting_botIdFallback_fkey` (`botIdFallback`),
  CONSTRAINT `EvolutionBotSetting_botIdFallback_fkey` FOREIGN KEY (`botIdFallback`) REFERENCES `evolutionbot` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `EvolutionBotSetting_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flowise`
--

DROP TABLE IF EXISTS `flowise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flowise` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiKey` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `triggerType` enum('all','keyword','none','advanced') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerOperator` enum('contains','equals','startsWith','endsWith','regex') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerValue` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  PRIMARY KEY (`id`),
  KEY `Flowise_instanceId_fkey` (`instanceId`),
  CONSTRAINT `Flowise_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flowisesetting`
--

DROP TABLE IF EXISTS `flowisesetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flowisesetting` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `flowiseIdFallback` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  PRIMARY KEY (`id`),
  UNIQUE KEY `FlowiseSetting_instanceId_key` (`instanceId`),
  KEY `FlowiseSetting_flowiseIdFallback_fkey` (`flowiseIdFallback`),
  CONSTRAINT `FlowiseSetting_flowiseIdFallback_fkey` FOREIGN KEY (`flowiseIdFallback`) REFERENCES `flowise` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `FlowiseSetting_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance`
--

DROP TABLE IF EXISTS `instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `instance` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connectionStatus` enum('open','close','connecting') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `ownerJid` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profileName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profilePicUrl` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `integration` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `businessId` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `clientName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `disconnectionReasonCode` int DEFAULT NULL,
  `disconnectionObject` json DEFAULT NULL,
  `disconnectionAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Instance_name_key` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `integrationsession`
--

DROP TABLE IF EXISTS `integrationsession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `integrationsession` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sessionId` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remoteJid` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pushName` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('opened','closed','paused') COLLATE utf8mb4_unicode_ci NOT NULL,
  `awaitUser` tinyint(1) NOT NULL DEFAULT '0',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `parameters` json DEFAULT NULL,
  `botId` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `context` json DEFAULT NULL,
  `type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IntegrationSession_instanceId_fkey` (`instanceId`),
  CONSTRAINT `IntegrationSession_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `isonwhatsapp`
--

DROP TABLE IF EXISTS `isonwhatsapp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `isonwhatsapp` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remoteJid` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `jidOptions` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `IsOnWhatsapp_remoteJid_key` (`remoteJid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kafka`
--

DROP TABLE IF EXISTS `kafka`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kafka` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `events` json NOT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Kafka_instanceId_key` (`instanceId`),
  CONSTRAINT `Kafka_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `label`
--

DROP TABLE IF EXISTS `label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `label` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `labelId` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `color` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `predefinedId` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Label_instanceId_fkey` (`instanceId`),
  CONSTRAINT `Label_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `media` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fileName` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mimetype` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `messageId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Media_messageId_key` (`messageId`),
  KEY `Media_instanceId_fkey` (`instanceId`),
  CONSTRAINT `Media_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Media_messageId_fkey` FOREIGN KEY (`messageId`) REFERENCES `message` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `key` json NOT NULL,
  `pushName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `participant` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `messageType` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` json NOT NULL,
  `contextInfo` json DEFAULT NULL,
  `source` enum('ios','android','web','unknown','desktop') COLLATE utf8mb4_unicode_ci NOT NULL,
  `messageTimestamp` int NOT NULL,
  `chatwootMessageId` int DEFAULT NULL,
  `chatwootInboxId` int DEFAULT NULL,
  `chatwootConversationId` int DEFAULT NULL,
  `chatwootContactInboxSourceId` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `chatwootIsRead` tinyint(1) DEFAULT '0',
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `typebotSessionId` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `webhookUrl` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sessionId` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Message_instanceId_idx` (`instanceId`),
  KEY `Message_sessionId_fkey` (`sessionId`),
  CONSTRAINT `Message_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Message_sessionId_fkey` FOREIGN KEY (`sessionId`) REFERENCES `integrationsession` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `messageupdate`
--

DROP TABLE IF EXISTS `messageupdate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messageupdate` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `keyId` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remoteJid` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fromMe` tinyint(1) NOT NULL,
  `participant` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pollUpdates` json DEFAULT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `messageId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `MessageUpdate_messageId_idx` (`messageId`),
  KEY `MessageUpdate_instanceId_idx` (`instanceId`),
  CONSTRAINT `MessageUpdate_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `MessageUpdate_messageId_fkey` FOREIGN KEY (`messageId`) REFERENCES `message` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `n8n`
--

DROP TABLE IF EXISTS `n8n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `n8n` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `webhookUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `basicAuthUser` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `basicAuthPass` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  `triggerType` enum('all','keyword','none','advanced') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerOperator` enum('contains','equals','startsWith','endsWith','regex') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerValue` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `N8n_instanceId_fkey` (`instanceId`),
  CONSTRAINT `N8n_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `n8nsetting`
--

DROP TABLE IF EXISTS `n8nsetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `n8nsetting` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `n8nIdFallback` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `N8nSetting_instanceId_key` (`instanceId`),
  KEY `N8nSetting_n8nIdFallback_fkey` (`n8nIdFallback`),
  CONSTRAINT `N8nSetting_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `N8nSetting_n8nIdFallback_fkey` FOREIGN KEY (`n8nIdFallback`) REFERENCES `n8n` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nats`
--

DROP TABLE IF EXISTS `nats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nats` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `events` json NOT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Nats_instanceId_key` (`instanceId`),
  CONSTRAINT `Nats_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `openaibot`
--

DROP TABLE IF EXISTS `openaibot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `openaibot` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `botType` enum('assistant','chatCompletion') COLLATE utf8mb4_unicode_ci NOT NULL,
  `assistantId` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `functionUrl` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `systemMessages` json DEFAULT NULL,
  `assistantMessages` json DEFAULT NULL,
  `userMessages` json DEFAULT NULL,
  `maxTokens` int DEFAULT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `triggerType` enum('all','keyword','none','advanced') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerOperator` enum('contains','equals','startsWith','endsWith','regex') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerValue` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `openaiCredsId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  PRIMARY KEY (`id`),
  KEY `OpenaiBot_openaiCredsId_fkey` (`openaiCredsId`),
  KEY `OpenaiBot_instanceId_fkey` (`instanceId`),
  CONSTRAINT `OpenaiBot_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `OpenaiBot_openaiCredsId_fkey` FOREIGN KEY (`openaiCredsId`) REFERENCES `openaicreds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `openaicreds`
--

DROP TABLE IF EXISTS `openaicreds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `openaicreds` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiKey` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `OpenaiCreds_name_key` (`name`),
  UNIQUE KEY `OpenaiCreds_apiKey_key` (`apiKey`),
  KEY `OpenaiCreds_instanceId_fkey` (`instanceId`),
  CONSTRAINT `OpenaiCreds_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `openaisetting`
--

DROP TABLE IF EXISTS `openaisetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `openaisetting` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `speechToText` tinyint(1) DEFAULT '0',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `openaiCredsId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `openaiIdFallback` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `splitMessages` tinyint(1) DEFAULT '0',
  `timePerChar` int DEFAULT '50',
  PRIMARY KEY (`id`),
  UNIQUE KEY `OpenaiSetting_openaiCredsId_key` (`openaiCredsId`),
  UNIQUE KEY `OpenaiSetting_instanceId_key` (`instanceId`),
  KEY `OpenaiSetting_openaiIdFallback_fkey` (`openaiIdFallback`),
  CONSTRAINT `OpenaiSetting_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `OpenaiSetting_openaiCredsId_fkey` FOREIGN KEY (`openaiCredsId`) REFERENCES `openaicreds` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `OpenaiSetting_openaiIdFallback_fkey` FOREIGN KEY (`openaiIdFallback`) REFERENCES `openaibot` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `proxy`
--

DROP TABLE IF EXISTS `proxy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proxy` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `host` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `port` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `protocol` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Proxy_instanceId_key` (`instanceId`),
  CONSTRAINT `Proxy_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pusher`
--

DROP TABLE IF EXISTS `pusher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pusher` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `appId` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `secret` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cluster` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `useTLS` tinyint(1) NOT NULL DEFAULT '0',
  `events` json NOT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Pusher_instanceId_key` (`instanceId`),
  CONSTRAINT `Pusher_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rabbitmq`
--

DROP TABLE IF EXISTS `rabbitmq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rabbitmq` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `events` json NOT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Rabbitmq_instanceId_key` (`instanceId`),
  CONSTRAINT `Rabbitmq_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `session` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sessionId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `creds` text COLLATE utf8mb4_unicode_ci,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Session_sessionId_key` (`sessionId`),
  CONSTRAINT `Session_sessionId_fkey` FOREIGN KEY (`sessionId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `setting`
--

DROP TABLE IF EXISTS `setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `setting` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rejectCall` tinyint(1) NOT NULL DEFAULT '0',
  `msgCall` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `groupsIgnore` tinyint(1) NOT NULL DEFAULT '0',
  `alwaysOnline` tinyint(1) NOT NULL DEFAULT '0',
  `readMessages` tinyint(1) NOT NULL DEFAULT '0',
  `readStatus` tinyint(1) NOT NULL DEFAULT '0',
  `syncFullHistory` tinyint(1) NOT NULL DEFAULT '0',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `wavoipToken` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Setting_instanceId_key` (`instanceId`),
  KEY `Setting_instanceId_idx` (`instanceId`),
  CONSTRAINT `Setting_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sqs`
--

DROP TABLE IF EXISTS `sqs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sqs` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `events` json NOT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Sqs_instanceId_key` (`instanceId`),
  CONSTRAINT `Sqs_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `template`
--

DROP TABLE IF EXISTS `template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `template` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `templateId` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template` json NOT NULL,
  `webhookUrl` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Template_templateId_key` (`templateId`),
  UNIQUE KEY `Template_name_key` (`name`),
  KEY `Template_instanceId_fkey` (`instanceId`),
  CONSTRAINT `Template_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `typebot`
--

DROP TABLE IF EXISTS `typebot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `typebot` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `typebot` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `triggerType` enum('all','keyword','none','advanced') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerOperator` enum('contains','equals','startsWith','endsWith','regex') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `triggerValue` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Typebot_instanceId_fkey` (`instanceId`),
  CONSTRAINT `Typebot_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `typebotsetting`
--

DROP TABLE IF EXISTS `typebotsetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `typebotsetting` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire` int DEFAULT '0',
  `keywordFinish` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delayMessage` int DEFAULT NULL,
  `unknownMessage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listeningFromMe` tinyint(1) DEFAULT '0',
  `stopBotFromMe` tinyint(1) DEFAULT '0',
  `keepOpen` tinyint(1) DEFAULT '0',
  `debounceTime` int DEFAULT NULL,
  `typebotIdFallback` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ignoreJids` json DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `TypebotSetting_instanceId_key` (`instanceId`),
  KEY `TypebotSetting_typebotIdFallback_fkey` (`typebotIdFallback`),
  CONSTRAINT `TypebotSetting_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `TypebotSetting_typebotIdFallback_fkey` FOREIGN KEY (`typebotIdFallback`) REFERENCES `typebot` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `webhook`
--

DROP TABLE IF EXISTS `webhook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) DEFAULT '1',
  `events` json DEFAULT NULL,
  `webhookByEvents` tinyint(1) DEFAULT '0',
  `webhookBase64` tinyint(1) DEFAULT '0',
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `headers` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Webhook_instanceId_key` (`instanceId`),
  KEY `Webhook_instanceId_idx` (`instanceId`),
  CONSTRAINT `Webhook_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `websocket`
--

DROP TABLE IF EXISTS `websocket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `websocket` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `events` json NOT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL,
  `instanceId` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Websocket_instanceId_key` (`instanceId`),
  CONSTRAINT `Websocket_instanceId_fkey` FOREIGN KEY (`instanceId`) REFERENCES `instance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'evolution'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:20:31
