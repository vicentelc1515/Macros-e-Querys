----------------------------------------------------------------------------------------------------
-------------------------------------------PARTE 1--------------------------------------------------
----------------------------------------------------------------------------------------------------
/*
	ATUALIZANDO AS CELULAS DE PR
	DESCOMENTE E RODE ESSE CÓDIGO, E DEPOIS COMENTE NOVAMENTE ANTES DE RODAR O KPI DE FATO
*/
--DROP TABLE IF EXISTS [SAGI].[dbo].[celulasPR]

--CREATE TABLE [SAGI].[dbo].[celulasPR] (
--		[UF] NVARCHAR(100)
--      ,[ANG] NVARCHAR(100)
--      ,[Chave célula] NVARCHAR(100)
--      ,[CHAVE] NVARCHAR(100)
--      ,[FIM_PROJETO] NVARCHAR(100)
--      ,[MES] NVARCHAR(100)
--)

--BULK INSERT [SAGI].[dbo].[celulasPR]
--FROM 'C:\LOGICTEL\DOWNLOAD\KPI\celulasPR.csv'
--WITH (
--   FIELDTERMINATOR = ';',
--   ROWTERMINATOR = '\n',
--   FIRSTROW = 2
--);
--SELECT * FROM [SAGI].[dbo].[celulasPR]



DROP TABLE IF EXISTS KPI.dbo.BASE

CREATE TABLE KPI.dbo.BASE(
	UF NVARCHAR(10),
	ESTACAO NVARCHAR(10),
	CELULA INT,
	REG NVARCHAR(10),
	CHAVE NVARCHAR(40),
	DATA_CONCLUSAO DATE,
	CADASTRO_NETWIN NVARCHAR(40),
	STATUS_CADASTRO_NETWIN NVARCHAR(40),
	SURVEYS_ASSOCIADOS NVARCHAR(40),
	STATUS_SURVEYS_ASSOCIADOS NVARCHAR(40),
	SN NVARCHAR(40),
	BASTIDOR NVARCHAR(40),
	STATUS_BASTIDOR NVARCHAR(40),
	MES NVARCHAR(40),
	HPS NVARCHAR(40),
	CONT_SURVEY NVARCHAR(40),
	HPS_PARCIAL_MENOR_IGUAL12 NVARCHAR(40),
	CONT_PARCIAL_MENOR_IGUAL12 NVARCHAR(40),
	HPS_EDIFICIO_MENOR_IGUAL12 NVARCHAR(40),
	CONT_EDIFICIO_MENOR_IGUAL12 NVARCHAR(40),
	HPS_PARCIAL_MAIOR12 NVARCHAR(40),
	CONT_PARCIAL_MAIOR12 NVARCHAR(40),
	HPS_EDIFICIO_MAIOR_12 NVARCHAR(40),
	CONT_EDIFICIO_MAIOR_12 NVARCHAR(40),
	HPS_EDIFICIOS NVARCHAR(40),
	CONT_EDIFICIOS NVARCHAR(40)
)

  ---------AUDITORIA

DROP TABLE IF EXISTS KPI.dbo.Projeto_Sec


SELECT
                    
                    CTRL.UF AS ESTADO, 
                    CTRL.Estacao,
                    CTRL.CELULA AS ANG, 
					CTRL.UF+CTRL.Estacao+CTRL.CELULA AS ID_CELULAS,
					ET.*

 
INTO KPI.dbo.Projeto_Sec

FROM (
  
  SELECT x.* FROM OPENROWSET(  
   BULK 'C:\LOGICTEL\DOWNLOAD\Enderecos_Totais_20231116.csv',  
   FORMATFILE = 'C:\LOGICTEL\DOWNLOAD\BIEL\totais.xml',
   CODEPAGE = 1252,
   FIRSTROW = 2) AS x
   
  ) AS ET



RIGHT JOIN (SELECT [UF], [Estacao], [Celula], [CHAVE]
FROM SAGI.dbo.CELULAS
UNION
SELECT [UF], [ANG], [Chave célula], [CHAVE]
FROM SAGI.dbo.celulasPR) AS CTRL

ON ET.CELULA LIKE (CTRL.Celula+ ' (' + CTRL.Estacao+ ')%' ) AND ET.UF = CTRL.UF 


----------------------------------------------------------
-- Gerando a tabela de edificação parcial
DROP TABLE IF EXISTS KPI.dbo.Projeto_Sec_Parcial
SELECT *
INTO KPI.dbo.Projeto_Sec_Parcial
FROM KPI.dbo.Projeto_Sec
WHERE tipo_survey = 'EDIFICACAO PARCIAL'

ALTER TABLE KPI.dbo.Projeto_Sec_Parcial
ADD CONTAGEM NVARCHAR(10),
	SOMA NVARCHAR(10),
	Chave_LNRS NVARCHAR(200),
	REP_UNICA INTEGER


UPDATE Projeto_Sec_Parcial
SET Chave_LNRS = CONCAT(logradouro,num_fachada,cep,bairro)
FROM KPI.dbo.Projeto_Sec_Parcial


----------------------------------------------------------------------------------------------------
-------------------------------------------PARTE 2--------------------------------------------------
----------------------------------------------------------------------------------------------------



INSERT INTO KPI.dbo.BASE(UF,ESTACAO,CELULA,CHAVE)
	(SELECT cc.UF, cc.Estacao, cc.Celula, cc.CHAVE
	FROM SAGI.dbo.CELULAS AS cc
	UNION
	SELECT pr.UF, pr.ANG, pr.[Chave célula], pr.CHAVE
	FROM SAGI.dbo.celulasPR AS pr)


-------------------------------------------------------
-- SETANDO VALOR ZERO PARA AS COLUNAS DE HP'S ATÉ CONT EDIFICIO
UPDATE KPI.[dbo].[BASE]
SET HPS = 0,
CONT_SURVEY = 0,
HPS_PARCIAL_MENOR_IGUAL12 = 0,
CONT_PARCIAL_MENOR_IGUAL12 = 0,
HPS_EDIFICIO_MENOR_IGUAL12 = 0,
CONT_EDIFICIO_MENOR_IGUAL12 = 0,
HPS_PARCIAL_MAIOR12 = 0,
CONT_PARCIAL_MAIOR12 = 0,
HPS_EDIFICIO_MAIOR_12 = 0,
CONT_EDIFICIO_MAIOR_12 = 0,
HPS_EDIFICIOS = 0,
CONT_EDIFICIOS = 0;


-------------------------------------------------------

--INSERINDO VALORES DE PROJ SECUNDÁRIO NA TABELA BASE--

-------------------------------------------------------

DROP TABLE IF EXISTS #CONT_SURVEY

CREATE TABLE #CONT_SURVEY(
	QTD_SURVEY NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #CONT_SURVEY
	SELECT COUNT(cod_survey) AS Survey, ID_CELULAS
	FROM KPI.dbo.Projeto_Sec
	GROUP BY ID_CELULAS


UPDATE KPI.[dbo].BASE
SET CONT_SURVEY = QTD_SURVEY
FROM KPI.dbo.BASE AS BB
INNER JOIN #CONT_SURVEY AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL

-------------------------------------------------------

DROP TABLE IF EXISTS #CELULA_QTD_UMS

CREATE TABLE #CELULA_QTD_UMS(
	QTD_UMS NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)

INSERT INTO #CELULA_QTD_UMS
	SELECT SUM(CAST(qtd_ums AS int)) AS qdt_UM, ID_CELULAS
	FROM KPI.dbo.Projeto_Sec
	GROUP BY ID_CELULAS

-- ADICIONA INFORMAÇÃO NA COLUNA 'HPS' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET HPS = QTD_UMS
FROM KPI.dbo.BASE AS BB
INNER JOIN #CELULA_QTD_UMS AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL
------

-------------------------------------------------------

DROP TABLE IF EXISTS #SOMA_HPS

CREATE TABLE #SOMA_HPS(
	QTD_UM NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #SOMA_HPS
	SELECT SUM(CAST(qtd_ums AS int)) AS qtd_UM, ID_CELULAS
	--FROM KPI.dbo.Projeto_Sec_Parcial_HP_MenorIgual12
	FROM KPI.dbo.Projeto_Sec
	WHERE tipo_survey = 'EDIFICACAO PARCIAL' AND qtd_ums <= 12
	GROUP BY ID_CELULAS

-- ADICIONA INFORMAÇÃO NA COLUNA 'HPS_PARCIAL_MENOR_IGUAL12' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET HPS_PARCIAL_MENOR_IGUAL12 = qtd_UM
FROM KPI.dbo.BASE AS BB
INNER JOIN #SOMA_HPS AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL


-------------------------------------------------------

DROP TABLE IF EXISTS #CONT_PARCIAL_SURVEY

CREATE TABLE #CONT_PARCIAL_SURVEY(
	QTD_SURVEY NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #CONT_PARCIAL_SURVEY
	SELECT COUNT(cod_survey) AS Survey, ID_CELULAS
	--FROM Projeto_Sec_Parcial_HP_MenorIgual12
	FROM KPI.[dbo].Projeto_Sec
	WHERE tipo_survey = 'EDIFICACAO PARCIAL' AND qtd_ums <= 12
	GROUP BY ID_CELULAS

-- ADICIONA INFORMAÇÃO NA COLUNA 'CONT_PARCIAL_MENOR_IGUAL12' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET CONT_PARCIAL_MENOR_IGUAL12 = QTD_SURVEY
FROM KPI.dbo.BASE AS BB
INNER JOIN #CONT_PARCIAL_SURVEY AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL



-------------------------------------------------------

DROP TABLE IF EXISTS #SOMA_HPS_EDIFICIO_MENOR12

CREATE TABLE #SOMA_HPS_EDIFICIO_MENOR12(
	QTD_UM NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #SOMA_HPS_EDIFICIO_MENOR12
	SELECT SUM(CAST(qtd_ums AS int)) AS qtd_UM, ID_CELULAS
	--FROM KPI.[dbo].Projeto_Sec_ParcialECompleta
	FROM KPI.[dbo].Projeto_Sec
	WHERE tipo_survey IN ('EDIFICACAO PARCIAL','EDIFICACAO COMPLETA') AND qtd_ums <= 12
	GROUP BY ID_CELULAS

-- ADICIONA INFORMAÇÃO NA COLUNA 'HPS_EDIFICIO_MENOR_IGUAL12' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET HPS_EDIFICIO_MENOR_IGUAL12 = qtd_UM
FROM KPI.dbo.BASE AS BB
INNER JOIN #SOMA_HPS_EDIFICIO_MENOR12 AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL




-------------------------------------------------------

DROP TABLE IF EXISTS #CONT_EDIF_PARCIAL_SURVEY

CREATE TABLE #CONT_EDIF_PARCIAL_SURVEY(
	QTD_SURVEY NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #CONT_EDIF_PARCIAL_SURVEY
	SELECT COUNT(cod_survey) AS Survey, ID_CELULAS
	--FROM KPI.[dbo].Projeto_Sec_ParcialECompleta
	FROM KPI.[dbo].Projeto_Sec
	WHERE tipo_survey IN ('EDIFICACAO PARCIAL','EDIFICACAO COMPLETA') AND qtd_ums <= 12
	GROUP BY ID_CELULAS

-- ADICIONA INFORMAÇÃO NA COLUNA 'CONT_EDIFICIO_MENOR_IGUAL12' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET CONT_EDIFICIO_MENOR_IGUAL12 = QTD_SURVEY
FROM KPI.dbo.BASE AS BB
INNER JOIN #CONT_EDIF_PARCIAL_SURVEY AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL



-------------------------------------------------------


DROP TABLE IF EXISTS #SOMA_HPS_PARCIAL_MAIOR12

CREATE TABLE #SOMA_HPS_PARCIAL_MAIOR12(
	QTD_UM NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #SOMA_HPS_PARCIAL_MAIOR12
	SELECT SUM(CAST(qtd_ums AS int)) AS qtd_UM, ID_CELULAS
	--FROM KPI.[dbo].Projeto_Sec_Parcial_HP_Maior12
	FROM KPI.[dbo].Projeto_Sec
	WHERE tipo_survey = 'EDIFICACAO PARCIAL' AND qtd_ums > 12
	GROUP BY ID_CELULAS

-- ADICIONA INFORMAÇÃO NA COLUNA 'HPS_PARCIAL_MAIOR12' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET HPS_PARCIAL_MAIOR12 = qtd_UM
FROM KPI.dbo.BASE AS BB
INNER JOIN #SOMA_HPS_PARCIAL_MAIOR12 AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL




-------------------------------------------------------

DROP TABLE IF EXISTS #CONT_PARCIAL_SURVEY_MAIOR12

CREATE TABLE #CONT_PARCIAL_SURVEY_MAIOR12(
	QTD_SURVEY NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #CONT_PARCIAL_SURVEY_MAIOR12
	SELECT COUNT(cod_survey) AS Survey, ID_CELULAS
	--FROM KPI.[dbo].Projeto_Sec_Parcial_HP_Maior12
	FROM KPI.[dbo].Projeto_Sec
	WHERE tipo_survey = 'EDIFICACAO PARCIAL' AND qtd_ums > 12
	GROUP BY ID_CELULAS


-- ADICIONA INFORMAÇÃO NA COLUNA 'CONT_PARCIAL_MAIOR_IGUAL12' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET CONT_PARCIAL_MAIOR12 = QTD_SURVEY
FROM KPI.dbo.BASE AS BB
INNER JOIN #CONT_PARCIAL_SURVEY_MAIOR12 AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL


-------------------------------------------------------


DROP TABLE IF EXISTS #SOMA_HPS_EDIFICIO_MAIOR12

CREATE TABLE #SOMA_HPS_EDIFICIO_MAIOR12(
	QTD_UM NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #SOMA_HPS_EDIFICIO_MAIOR12
	SELECT SUM(CAST(qtd_ums AS int)) AS qtd_UM, ID_CELULAS
	--FROM KPI.[dbo].Projeto_Sec_ParcialECompleta
	FROM KPI.[dbo].Projeto_Sec
	WHERE tipo_survey IN ('EDIFICACAO PARCIAL','EDIFICACAO COMPLETA') AND qtd_ums > 12
	GROUP BY ID_CELULAS

-- ADICIONA INFORMAÇÃO NA COLUNA 'HPS_EDIFICIO_MAIOR12' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET HPS_EDIFICIO_MAIOR_12 = qtd_UM
FROM KPI.dbo.BASE AS BB
INNER JOIN #SOMA_HPS_EDIFICIO_MAIOR12 AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL



-------------------------------------------------------

DROP TABLE IF EXISTS #CONT_EDIF_SURVEY_MAIOR12

CREATE TABLE #CONT_EDIF_SURVEY_MAIOR12(
	QTD_SURVEY NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)

INSERT INTO #CONT_EDIF_SURVEY_MAIOR12
	SELECT COUNT(cod_survey) AS Qtd_Survey, ID_CELULAS
	FROM KPI.[dbo].Projeto_Sec
	WHERE qtd_ums > 12 AND tipo_survey IN ('EDIFICACAO COMPLETA','EDIFICACAO PARCIAL')
	GROUP BY ID_CELULAS

-- ADICIONA INFORMAÇÃO NA COLUNA 'CONT_EDIFICIO_MAIOR_IGUAL12' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET CONT_EDIFICIO_MAIOR_12 = QTD_SURVEY
FROM KPI.dbo.BASE AS BB
INNER JOIN #CONT_EDIF_SURVEY_MAIOR12 AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL





-------------------------------------------------------

DROP TABLE IF EXISTS #SOMA_HPS_EDIFICIO

CREATE TABLE #SOMA_HPS_EDIFICIO(
	QTD_UM NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #SOMA_HPS_EDIFICIO
	SELECT SUM(CAST(qtd_ums AS int)) AS qtd_UM, ID_CELULAS
	--FROM KPI.[dbo].Projeto_Sec_ParcialECompleta
	FROM KPI.[dbo].Projeto_Sec
	WHERE tipo_survey IN ('EDIFICACAO PARCIAL','EDIFICACAO COMPLETA')
	GROUP BY ID_CELULAS

-- ADICIONA INFORMAÇÃO NA COLUNA 'HPS_EDIFICIO' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET HPS_EDIFICIOS = qtd_UM
FROM KPI.dbo.BASE AS BB
INNER JOIN #SOMA_HPS_EDIFICIO AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL




-------------------------------------------------------

DROP TABLE IF EXISTS #CONT_EDIF_SURVEY

CREATE TABLE #CONT_EDIF_SURVEY(
	QTD_SURVEY NVARCHAR(10),
	CHAVE NVARCHAR(20)
	)
-----
INSERT INTO #CONT_EDIF_SURVEY
	SELECT COUNT(cod_survey) AS Survey, ID_CELULAS
	--FROM KPI.[dbo].Projeto_Sec_ParcialECompleta
	FROM KPI.[dbo].Projeto_Sec
	WHERE tipo_survey IN ('EDIFICACAO PARCIAL','EDIFICACAO COMPLETA')
	GROUP BY ID_CELULAS



-- ADICIONA INFORMAÇÃO NA COLUNA 'CONT_EDIFICIOS' DA TABELA BASE
UPDATE KPI.[dbo].BASE
SET CONT_EDIFICIOS = QTD_SURVEY
FROM KPI.dbo.BASE AS BB
INNER JOIN #CONT_EDIF_SURVEY AS CC
ON BB.CHAVE = CC.CHAVE
WHERE BB.CHAVE IS NOT NULL


-------------------------------------------------------
-------- INSERINDO A REGIONAL NA TABELA BASE ----------
-------------------------------------------------------

UPDATE KPI.[dbo].BASE
SET REG = REGIONAL
FROM KPI.dbo.BASE AS BB
INNER JOIN (
	SELECT bb.CHAVE, bb.UF, re.REGIONAL
	FROM KPI.dbo.REGIONAL_DEPARA AS re
	INNER JOIN KPI.dbo.BASE AS bb ON bb.UF = re.UF
) AS reg
ON BB.CHAVE = reg.CHAVE



-------------------------------------------------------
---- INSERINDO A DATA DE CONCLUSÃO NA TABELA BASE -----
-------------------------------------------------------


UPDATE KPI.[dbo].BASE
SET DATA_CONCLUSAO = data_da_conclusão
FROM KPI.dbo.BASE AS BB
INNER JOIN (
	SELECT DISTINCT UF + Estacao + Celula AS CHAVE, data_da_conclusão
	FROM SAGI.dbo.EXTRACAO_SAGI
) AS con
ON BB.CHAVE = con.CHAVE


-------------------------------------------------------
---------- INSERINDO O MÊS NA TABELA BASE -------------
-------------------------------------------------------


UPDATE KPI.[dbo].BASE
SET MES = MESEXTENSO
FROM KPI.[dbo].BASE AS bb
INNER JOIN (
	SELECT DISTINCT UF + Estacao + Celula AS CHAVE, MESEXTENSO
	FROM SAGI.dbo.EXTRACAO_SAGI
	) AS mm
ON bb.CHAVE = mm.CHAVE


---------------------------------------------------------
----------------- LISTA DE EXCEÇÕES ---------------------
----------------- CELLS CANCELADAS ----------------------
---------------------------------------------------------


UPDATE KPI.[dbo].BASE
SET BASTIDOR = 'CANCELADO',
	STATUS_BASTIDOR = 'OK',
	CADASTRO_NETWIN = 'OK',
	STATUS_CADASTRO_NETWIN = 'OK',
	STATUS_SURVEYS_ASSOCIADOS = 'OK',
	SURVEYS_ASSOCIADOS = '0',
    SN = '0'
FROM KPI.[dbo].BASE AS bb
WHERE CHAVE IN ('RJDQS1','RJDQS2','RJDQS3','RJDQS4','RJDQS5','RJFRE133','RJFRE134','SPJCM25','BABRRR384','RJFRE154', 'SPJCM35', 'SPJCM36', 'SPVNB66','BASTEL39',
'BASTEL40','PAPUPB1','PAPUPB2','PAPUPB3','PAPUPB4','PAPUPB5','PAPUPB6','PAPUPB7','PAPUPB8','PAPUPB9','PAPUPB10','PAPUPB11','PAPUPB12','PAPUPB13','PAPUPB14','PAPUPB1',
'PAPUPB16','PAPUPB17','SPCJD175','PAPUP4', 'PAPUP5', 'PAPUP6', 'PAPUP7', 'PAPUP8', 'PAPUP9', 'PAPUP10', 'PAPU11', 'PAPU12', 'PAPU13', 'PAPU14', 'PAPU15', 'PAPU16', 'PAPU17')



UPDATE KPI.[dbo].BASE
SET BASTIDOR = 'SERÁ ALTERADA A ESTAÇÃO',
	STATUS_BASTIDOR = 'OK',
	CADASTRO_NETWIN = 'OK',
	STATUS_CADASTRO_NETWIN = 'OK',
	STATUS_SURVEYS_ASSOCIADOS = 'OK',
	SURVEYS_ASSOCIADOS = '0',
    SN = '0'
FROM KPI.[dbo].BASE AS bb
WHERE CHAVE IN ('PAAIU23', 'PAAIU24', 'PAAIU25', 'PAAIU26', 'PAAIU27', 'PAAIU28', 'PAAIU29', 'PAAIU30', 'PAAIU31', 'PAAIU32', 
'PAAIU33', 'PAAIU34', 'PAAIU35', 'PAAIU36', 'PAAIU37', 'PAAIU38', 'PAAIU39', 'PAAIU40')


UPDATE KPI.[dbo].BASE
SET STATUS_BASTIDOR = 'OK'
FROM KPI.[dbo].BASE AS bb
INNER JOIN (
	SELECT ID_CELULAS
	FROM KPI.dbo.Projeto_Sec
	WHERE uf IS NULL) AS pp
ON bb.CHAVE = pp.ID_CELULAS



---------------------------------------------------------
----- PREENCHE O BASTIDOR COM - PARA PS CASOS DE PR -----
------ PREENCHE O STATUS, DATA DE CONCLUSÃO E MES -------
-------------------- DOS CASOS DE PR --------------------
---------------------------------------------------------


UPDATE KPI.[dbo].BASE
SET BASTIDOR = '-',
	STATUS_BASTIDOR = 'OK',
	DATA_CONCLUSAO = FIM_PROJETO,
	MES = pp.MES
FROM KPI.[dbo].BASE AS bb
INNER JOIN (
	SELECT *
	FROM SAGI.dbo.celulasPR ) AS pp
ON bb.CHAVE = pp.CHAVE


UPDATE KPI.dbo.BASE
SET BASTIDOR = pp.BASTIDOR,
	STATUS_BASTIDOR = 'OK'
FROM KPI.dbo.BASE as bb
INNER JOIN KPI.dbo.celulas_bastidorOk AS pp
ON bb.CHAVE = pp.CHAVE

-----------------------------------------------------------------
-----------------MOSTRA QTD DE CELLS PARA VERIFICAR-----------------------
-----------------------------------------------------------------

--SELECT UF,COUNT([UF]) QTD_CEL
--  FROM [KPI].[dbo].[BASE]
--  WHERE BASTIDOR IS NULL
--  GROUP BY UF

--SELECT sum(tt.QTD_CEL) as qtd_cel_NOK
--FROM (SELECT UF,COUNT([UF]) QTD_CEL
--  FROM [KPI].[dbo].[BASE]
--  WHERE BASTIDOR IS NULL
--  GROUP BY UF
--  ) as tt

-----------------------------------------------------------------
----- INSERINDO A CONTAGEM E A SOMA NA TABELA PARCIAL DO PS -----
-----------------------------------------------------------------


-- INSERINDO VALORES EM CONTAGEM DO PROJETO_SEC_PARCIAL

UPDATE KPI.[dbo].Projeto_Sec_Parcial
SET CONTAGEM = QTD
FROM KPI.[dbo].Projeto_Sec_Parcial AS pp
INNER JOIN (
	SELECT ID_CELULAS,CONCAT_WS('_',logradouro,num_fachada,bairro,municipio) AS CHAVE, COUNT(CONCAT_WS('_',logradouro,num_fachada,bairro,municipio)) AS QTD
	FROM KPI.dbo.Projeto_Sec_Parcial
	GROUP BY ID_CELULAS, CONCAT_WS('_',logradouro,num_fachada,bairro,municipio)
) AS cc
ON pp.ID_CELULAS = cc.ID_CELULAS



-- INSERINDO VALORES EM SOMA DO PROJETO_SEC_PARCIAL
UPDATE KPI.[dbo].Projeto_Sec_Parcial
SET SOMA = SOMA_UMS
FROM KPI.[dbo].Projeto_Sec_Parcial AS pp
INNER JOIN (
	SELECT ID_CELULAS,CONCAT_WS('_',logradouro,num_fachada,bairro,municipio) AS CHAVE, SUM(CAST(qtd_ums AS int)) AS SOMA_UMS
	FROM KPI.dbo.Projeto_Sec_Parcial
	GROUP BY ID_CELULAS, CONCAT_WS('_',logradouro,num_fachada,bairro,municipio)
) AS cc
ON pp.ID_CELULAS = cc.ID_CELULAS

--DROP TABLE IF EXISTS KPI.dbo.celulas_bastidorOk

--------------------------------------------------------
-------------- NOVAS COLUNAS DA MARCIA -----------------
--------------------------------------------------------
/*

SELECT ROW_NUMBER() OVER (ORDER BY CONCAT([logradouro], [num_fachada] ,[cep], [bairro])) AS 'INDEX', *, CONCAT([logradouro], [num_fachada] ,[cep], [bairro]) as cc
INTO #parcial_index
FROM [KPI].[dbo].[Projeto_Sec_Parcial]


DECLARE @contador INT
DECLARE @row_max INT
SET @contador = 1
SELECT @row_max = COUNT(*) FROM [KPI].[dbo].[Projeto_Sec_Parcial]
PRINT ('TT_LINHAS: ' + CAST(@row_max AS NVARCHAR(10)))

WHILE (@contador <= @row_max)
BEGIN
	SELECT * 
	FROM (
	SELECT ROW_NUMBER() OVER (ORDER BY CONCAT([logradouro], [num_fachada] ,[cep], [bairro])) AS 'INDEX', *, CONCAT([logradouro], [num_fachada] ,[cep], [bairro]) as cc
	FROM [KPI].[dbo].[Projeto_Sec_Parcial]) as pla

	SET @contador = @contador + 1
END
*/


--update kpi.dbo.BASE
--set cadastro_netwin = '',
--	STATUS_BASTIDOR = '',
--	SURVEYS_ASSOCIADOS = '',
--	STATUS_SURVEYS_ASSOCIADOS = '',
--	SN = ''
--where CADASTRO_NETWIN = 'NULL'