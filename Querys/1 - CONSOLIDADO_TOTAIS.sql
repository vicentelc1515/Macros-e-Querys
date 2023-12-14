
---TRUNCATE TABLE TOTAIS_ACUMULADO.DBO.End_Totais_Consolidado
-----------------------------------------------------------------
--DELETE FROM TOTAIS_ACUMULADO.DBO.End_Totais_Consolidado
---WHERE UF IN ('AC', 'SC', 'DF', 'ES', 'GO', 'MG', 'MS', 'MT', 'RO', 'RS', 'TO')
DELETE FROM END_TOTAIS.DBO.Netwin_Totais
WHERE UF IN ('AC', 'SC', 'DF', 'ES', 'GO', 'MG', 'MS', 'MT', 'RO', 'RS', 'TO')
GO
--------------------------------------------------------------------------
--ALTER TABLE TOTAIS_ACUMULADO.dbo.End_Totais_Consolidado 
--ADD EMPRESA VARCHAR(55)


--ALTER TABLE TOTAIS_ACUMULADO.dbo.End_Totais_Consolidado DROP COLUMN [ANOMES]

--ALTER TABLE TOTAIS_ACUMULADO.dbo.End_Totais_Consolidado 
--ADD GANHO VARCHAR(55)
GO
ALTER TABLE END_TOTAIS.DBO.Netwin_Totais
ADD GANHO VARCHAR(55)
GO
ALTER TABLE END_TOTAIS.DBO.Netwin_Totais
ADD EMPRESA VARCHAR(55)
GO
-----------------------------------------------------
----2 - VERIFICA O QUE TEM NO ULTIMO END. TOTAIS QUE NAO TEM NO CONSOLIDADO(ULTIMA DATA REGISTRADA DE CADA SURVEY)
---E JOGA PARA O CONSOLIDADO
USE MES_2_CONSOLIDADO
DECLARE @FILE_DATE VARCHAR(255)
SET @FILE_DATE = (SELECT TOP 1 [FILE_DATE] FROM END_TOTAIS.DBO.FILE_LIST WHERE [IS_EARLIEST] = 1)

---INSERT INTO TOTAIS_ACUMULADO.DBO.End_Totais_Consolidado
INSERT INTO MES_2_CONSOLIDADO.DBO.End_Totais_Consolidado_SEC
SELECT @FILE_DATE AS DATA_ARQUIVO, RESULT.*
--SELECT RESULT.*
FROM (
		SELECT CELULA, ESTACAO_ABASTECEDORA, UF, MUNICIPIO, LOCALIDADE, COD_LOCALIDADE, LOCALIDADE_ABREV, LOGRADOURO, COD_LOGRADOURO, NUM_FACHADA, COMPLEMENTO, COMPLEMENTO2, COMPLEMENTO3, CEP, BAIRRO, COD_SURVEY, QTD_UMS, COD_VIABILIDADE, TIPO_VIABILIDADE, TIPO_REDE, UCS_RESIDENCIAIS, UCS_COMERCIAIS, NOME_CDO, ID_ENDERECO, LATITUDE, LONGITUDE, TIPO_SURVEY, REDE_INTERNA, UMS_CERTIFICADAS, REDE_EDIF_CERTIFICADA, NUM_PISOS, DISP_COMERCIAL, ESTADO_CONTROLE, DATA_ESTADO_CONTROLE, ID_CELULA, QUANTIDADE_HCS, PROJETO, EMPRESA, GANHO
		FROM END_TOTAIS.DBO.Netwin_Totais
	EXCEPT
		-- [Modificado] Retorna do Consolidado, a data mais recente de modifica��o, de cada Survey importado --
		SELECT DISTINCT TOP 3000 CELULA, ESTACAO_ABASTECEDORA, UF, MUNICIPIO, LOCALIDADE, COD_LOCALIDADE, LOCALIDADE_ABREV, LOGRADOURO, COD_LOGRADOURO, NUM_FACHADA, COMPLEMENTO, COMPLEMENTO2, COMPLEMENTO3, CEP, BAIRRO, COD_SURVEY, QTD_UMS, COD_VIABILIDADE, TIPO_VIABILIDADE, TIPO_REDE, UCS_RESIDENCIAIS, UCS_COMERCIAIS, NOME_CDO, ID_ENDERECO, LATITUDE, LONGITUDE, TIPO_SURVEY, REDE_INTERNA, UMS_CERTIFICADAS, REDE_EDIF_CERTIFICADA, NUM_PISOS, DISP_COMERCIAL, ESTADO_CONTROLE, DATA_ESTADO_CONTROLE, ID_CELULA, QUANTIDADE_HCS, PROJETO, EMPRESA, GANHO
		FROM TOTAIS_ACUMULADO.dbo.End_Totais_Consolidado AS TC
		INNER JOIN (
					SELECT DISTINCT COD_SURVEY AS SURVEY, CAST(MAX(CAST(DATA_ARQUIVO AS DATE))AS varchar) AS DT_ARQUIVO
					FROM TOTAIS_ACUMULADO.dbo.End_Totais_Consolidado
					GROUP BY COD_SURVEY
					) AS T2
		ON TC.COD_SURVEY = T2.SURVEY
		AND CAST(TC.DATA_ARQUIVO AS DATE) = CAST(T2.DT_ARQUIVO AS DATE)
		--------------------------------------------------------------------------------------------
) AS RESULT
GO
----------------------------------------------------------------------
--- DELETE INFORMA��O DA End_Totais_Cons_Aux(ELA QUE EST� SENDO A INTERMEDIARIA ENTRE O 
----END. TOTAIS ATUAL COM O CONSOLIDADO
--SELECT TOP 1 *
--INTO TOTAIS_ACUMULADO.DBO.End_Totais_Cons_Aux
--FROM TOTAIS_ACUMULADO.DBO.End_Totais_Consolidado

--DELETE FROM TOTAIS_ACUMULADO.DBO.End_Totais_Cons_Aux
-------------------------------------------------------------
-- 3 - DELETA O AUX E PEGA SURVEYS EXCLUIDOS, QUE CONT�M NO End_Totais_Consolidado E N�O NO Netwin_Totais
--- E JOGA NA PLANILHA AUXILIAR(QUE TEM QUE ESTAR ZERADA)
TRUNCATE TABLE TOTAIS_ACUMULADO.DBO.End_Totais_Cons_Aux
INSERT INTO TOTAIS_ACUMULADO.dbo.End_Totais_Cons_Aux
SELECT EC.*
FROM ( 
		-- \\\\[Modificado] Retorna do Consolidado, a data mais recente de modifica��o, de cada Survey importado --
		SELECT DISTINCT DATA_ARQUIVO, CELULA, ESTACAO_ABASTECEDORA, UF, MUNICIPIO, LOCALIDADE, COD_LOCALIDADE, LOCALIDADE_ABREV, LOGRADOURO, COD_LOGRADOURO, NUM_FACHADA, COMPLEMENTO, COMPLEMENTO2, COMPLEMENTO3, CEP, BAIRRO, COD_SURVEY, QTD_UMS, COD_VIABILIDADE, TIPO_VIABILIDADE, TIPO_REDE, UCS_RESIDENCIAIS, UCS_COMERCIAIS, NOME_CDO, ID_ENDERECO, LATITUDE, LONGITUDE, TIPO_SURVEY, REDE_INTERNA, UMS_CERTIFICADAS, REDE_EDIF_CERTIFICADA, NUM_PISOS, DISP_COMERCIAL, ESTADO_CONTROLE, DATA_ESTADO_CONTROLE, ID_CELULA, QUANTIDADE_HCS, PROJETO, EMPRESA, GANHO
		FROM TOTAIS_ACUMULADO.dbo.End_Totais_Consolidado AS TC
		INNER JOIN (
					SELECT DISTINCT COD_SURVEY AS SURVEY, MAX(DATA_ARQUIVO) AS DT_ARQUIVO
					FROM TOTAIS_ACUMULADO.dbo.End_Totais_Consolidado
					GROUP BY COD_SURVEY
					) AS T2
		ON TC.COD_SURVEY = T2.SURVEY
		AND TC.DATA_ARQUIVO = T2.DT_ARQUIVO
		----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	) AS EC
LEFT JOIN END_TOTAIS.dbo.Netwin_Totais AS NT
ON EC.COD_SURVEY = NT.COD_SURVEY
WHERE NT.COD_SURVEY IS NULL
AND EC.UF <> 'N�o Encontrado'
GO
-----------------------------------------------------------------------------------------
--- 4 - ALTERA DATA DE ARQUIVO PARA DATA ATUAL
--- E INCLUI N�o Encontrado, POIS SURVEYS POSSIVELMENTE FORAM EXCLUIDOS
USE END_TOTAIS
DECLARE @FILE_DATE1 VARCHAR(255)
SET @FILE_DATE1 = (SELECT TOP 1 [FILE_DATE] FROM END_TOTAIS.DBO.FILE_LIST WHERE [IS_EARLIEST] = 1)
--DECLARE @FILE_DATE_AUX VARCHAR(255)
--SET @FILE_DATE_AUX = (SELECT TOP 1 [DATA_ARQUIVO] FROM TESTE.DBO.End_Totais_Cons_Aux)
UPDATE TOTAIS_ACUMULADO.DBO.End_Totais_Cons_Aux
SET [DATA_ARQUIVO] = @FILE_DATE1, CELULA = 'N�o Encontrado', ESTACAO_ABASTECEDORA = 'N�o Encontrado', UF = 'N�o Encontrado', MUNICIPIO = 'N�o Encontrado', [LOCALIDADE] = 'N�o Encontrado', [COD_LOCALIDADE] = 'N�o Encontrado', [LOCALIDADE_ABREV] = 'N�o Encontrado', [LOGRADOURO] = 'N�o Encontrado', [COD_LOGRADOURO] = 'N�o Encontrado', [NUM_FACHADA] = 'N�o Encontrado', [COMPLEMENTO] = 'N�o Encontrado', [COMPLEMENTO2] = 'N�o Encontrado', [COMPLEMENTO3] = 'N�o Encontrado', [CEP] = 'N�o Encontrado', [BAIRRO] = 'N�o Encontrado', [QTD_UMS] = 'N�o Encontrado', [COD_VIABILIDADE] = 'N�o Encontrado', [TIPO_VIABILIDADE] = 'N�o Encontrado', [TIPO_REDE] = 'N�o Encontrado', [UCS_RESIDENCIAIS] = 'N�o Encontrado', [UCS_COMERCIAIS] = 'N�o Encontrado', [NOME_CDO] = 'N�o Encontrado', [ID_ENDERECO] = 'N�o Encontrado', [LATITUDE] = 'N�o Encontrado', [LONGITUDE] = 'N�o Encontrado', [TIPO_SURVEY] = 'N�o Encontrado', [REDE_INTERNA] = 'N�o Encontrado', [UMS_CERTIFICADAS] = 'N�o Encontrado', [REDE_EDIF_CERTIFICADA] = 'N�o Encontrado', [NUM_PISOS] = 'N�o Encontrado', [DISP_COMERCIAL] = 'N�o Encontrado', [ESTADO_CONTROLE] = 'N�o Encontrado', [DATA_ESTADO_CONTROLE] = 'N�o Encontrado', [ID_CELULA] = 'N�o Encontrado', [QUANTIDADE_HCS] = 'N�o Encontrado', [PROJETO] = 'N�o Encontrado', EMPRESA = 'N�o Encontrado'
WHERE UF IS NOT NULL
GO
--------------------------------------------------------------------------------------------
---- 5 - JOGA SURVEYS EXCLUIDOS NA TABELA CONSOLIDADO
INSERT INTO TOTAIS_ACUMULADO.DBO.End_Totais_Consolidado
SELECT DISTINCT * FROM TOTAIS_ACUMULADO.DBO.End_Totais_Cons_Aux
---------------------------------------------------------------
---ADICIONAR CONTEUDO NA COLUNA GANHO
GO
  UPDATE TT
  SET TT.[GANHO] = ET.[ANOMES]
  FROM TOTAIS_ACUMULADO.DBO.End_Totais_Consolidado AS TT
  INNER JOIN ACUMULADA.DBO.ACUMULADA AS ET
  ON TT.COD_SURVEY = ET.[COD_SURVEY]