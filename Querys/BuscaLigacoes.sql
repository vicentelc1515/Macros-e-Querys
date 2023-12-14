/****** Script do comando SelectTopNRows de SSMS  ******/
--SELECT  *
--  FROM [END_TOTAIS].[dbo].[listacells]
--  LEFT JOIN OPENROWSET(  
--	BULK 'C:\LOGICTEL\DOWNLOAD\Enderecos_Totais_20230319.csv',  
--	FORMATFILE = 'C:\LOGICTEL\DOWNLOAD\BIEL\totais.xml',
--	FIRSTROW = 2) AS TT
--	ON [listacells].UF = [TT].uf AND
--	--[listacells].ANG = [TT].estacao_abastecedora AND
--	[TT].celula LIKE [listacells].CELULA + ' (' + listacells.ANG + '%'


 SELECT DISTINCT  UF,[NO],CELULA,DGO,ICX,CABO_DGO,FIBRA_DGO

  FROM OPENROWSET(  
	BULK 'C:\LOGICTEL\DOWNLOAD\LIGACOES_2023-08-20_20h56m.csv',  
	FORMATFILE = '\\192.168.0.204\Gestao Rede de Acesso\GESTAO_PROCESSOS\Equipe Sagi\Vicente\SQL\Format_File_LIGACOES.xml',
	FIRSTROW = 2,
	CODEPAGE = 65001) AS LIGA
	WHERE UF = 'BAHIA' AND NO = 'BDEA' AND CELULA = '1' AND DGO LIKE 'DGO-02%'
	ORDER BY DGO


	--AND DGO = 'DGO-01/MOD-04/07/22'  /* OR [NO] ='SOC1' AND CELULA = '574'