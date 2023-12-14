USE SAGI
GO
DROP TABLE IF EXISTS [Rel_Geral_Survey]
GO

CREATE TABLE [Rel_Geral_Survey] (
	[ID]						VARCHAR(100),
	[idSur]						VARCHAR(50),
	[Estação]					VARCHAR(50),
	[Número do Acionamento]		VARCHAR(255),
	[Número do Mapa]			VARCHAR(50),
	[Data da Inclusão]			VARCHAR(50),
	[Tipo do Edifício]			VARCHAR(50),
	[Nome do Edifício]			VARCHAR(50),
	[Endereço]					VARCHAR(255),
	[Núm. Lote]					VARCHAR(50),
	[Bloco]						VARCHAR(50),
	[Síndico]					VARCHAR(50),
	[Contato]					VARCHAR(255),
	[Status Survey]				VARCHAR(50),
	[Qtd UMs]					VARCHAR(50),
	[Observação]				VARCHAR(255),
	[Data Acionamento]			VARCHAR(50),
	[Data Hora Criação]			VARCHAR(50),
	[Data Início da Atividade]	VARCHAR(50),
	[Data da Conclusão]			VARCHAR(50),
	[Status]					VARCHAR(50),
	[Equipe]					VARCHAR(50),
	[Cliente]					VARCHAR(255),
	[Endereço Acionamento]		VARCHAR(255),
	[Status 2]					VARCHAR(50),
	[Segmento]					VARCHAR(50),
	[UF]						VARCHAR(50),
	[Resp Criação]				VARCHAR(50),
	[Data Hora Programada]		VARCHAR(50),
	[Descrição]					VARCHAR(255)
)
GO
TRUNCATE TABLE [Rel_Geral_Survey]
GO

DECLARE @Q NVARCHAR(MAX)

SET @Q = 'BULK INSERT [Rel_Geral_Survey]
 FROM ''C:\LOGICTEL\SAGI\REL_GERAL_SURVEY_ESTRUTURANTE_SQL.csv''
 WITH (FIRSTROW = 2, 
 DATAFILETYPE = ''char'',
 CODEPAGE = 1252,
 FIELDTERMINATOR = ''ß'',
 ROWTERMINATOR=''\n''
 );'
EXEC SP_EXECUTESQL @Q






