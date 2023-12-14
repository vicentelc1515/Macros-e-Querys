USE SAGI
GO
DROP TABLE IF EXISTS [Rel_Geral_Survey]
GO

CREATE TABLE [Rel_Geral_Survey] (
	[ID]						VARCHAR(100),
	[idSur]						VARCHAR(50),
	[Esta��o]					VARCHAR(50),
	[N�mero do Acionamento]		VARCHAR(255),
	[N�mero do Mapa]			VARCHAR(50),
	[Data da Inclus�o]			VARCHAR(50),
	[Tipo do Edif�cio]			VARCHAR(50),
	[Nome do Edif�cio]			VARCHAR(50),
	[Endere�o]					VARCHAR(255),
	[N�m. Lote]					VARCHAR(50),
	[Bloco]						VARCHAR(50),
	[S�ndico]					VARCHAR(50),
	[Contato]					VARCHAR(255),
	[Status Survey]				VARCHAR(50),
	[Qtd UMs]					VARCHAR(50),
	[Observa��o]				VARCHAR(255),
	[Data Acionamento]			VARCHAR(50),
	[Data Hora Cria��o]			VARCHAR(50),
	[Data In�cio da Atividade]	VARCHAR(50),
	[Data da Conclus�o]			VARCHAR(50),
	[Status]					VARCHAR(50),
	[Equipe]					VARCHAR(50),
	[Cliente]					VARCHAR(255),
	[Endere�o Acionamento]		VARCHAR(255),
	[Status 2]					VARCHAR(50),
	[Segmento]					VARCHAR(50),
	[UF]						VARCHAR(50),
	[Resp Cria��o]				VARCHAR(50),
	[Data Hora Programada]		VARCHAR(50),
	[Descri��o]					VARCHAR(255)
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
 FIELDTERMINATOR = ''�'',
 ROWTERMINATOR=''\n''
 );'
EXEC SP_EXECUTESQL @Q






