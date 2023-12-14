
SELECT TRIM(SS.COD_SURVEY), TT.uf, TT.estacao_abastecedora,TT.celula,TT.nome_cdo
FROM ASSOCIADOS..surveys_cdo AS SS
LEFT JOIN NETWIN_TOTAIS..ENDERECOS_TOTAIS AS TT
ON TRIM(SS.COD_SURVEY) = TRIM(TT.cod_survey)


SELECT DISTINCT TT.*, COUNT(AA.[Código Survey]) AS QTD_SURVEY, COUNT(AA.[CFS ACESSOGPON]) AS QTD_GPON, STRING_AGG(AA.[Código Survey],';') AS TURMINHA
FROM ASSOCIADOS..chave_totais AS TT
LEFT JOIN ASSOCIADOS..SERV_ASSOCIADOS AS AA
ON TT.[celula] = [Célula CEOS]
	AND TT.[estacao_abastecedora] = AA.[Sigla Est Abastecedora] 
	AND TT.[uf] = AA.[Sigla Unidade Federativa]
    AND TT.[nome_cdo] = AA.[CDOE I]
	GROUP BY TT.uf, TT.estacao_abastecedora,TT.celula,TT.nome_cdo




SELECT  TT.uf, TT.estacao_abastecedora,TT.celula,TT.nome_cdo, COUNT(T2.COD_SURVEY) AS QTD_SURVEY, STRING_AGG(T2.COD_SURVEY,';')
FROM ASSOCIADOS..chave_totais AS TT
LEFT JOIN NETWIN_TOTAIS..ENDERECOS_TOTAIS AS T2
ON T2.[celula] LIKE TT.[celula] + ' %'
	AND TT.[estacao_abastecedora] = T2.[estacao_abastecedora] 
	AND TT.[uf] = T2.[uf]
    AND TRIM(TT.[nome_cdo]) = TRIM(T2.[nome_cdo])
	GROUP BY TT.uf, TT.estacao_abastecedora,TT.celula,TT.nome_cdo



SELECT CC.uf, CC.estacao_abastecedora, CC.celula, CC.nome_cdo, COUNT(CC.[Código Survey]) AS QTD_SURVEYS, STRING_AGG(CC.[Código Survey],';') AS TURMINHA
FROM (
SELECT DISTINCT TT.*, AA.[Código Survey]
FROM ASSOCIADOS..chave_totais AS TT
LEFT JOIN ASSOCIADOS..SERV_ASSOCIADOS AS AA
ON TT.[celula] = [Célula CEOS]
	AND TT.[estacao_abastecedora] = AA.[Sigla Est Abastecedora] 
	AND TT.[uf] = AA.[Sigla Unidade Federativa]
    AND TT.[nome_cdo] = AA.[CDOE I]
	
) AS CC
GROUP BY CC.uf, CC.estacao_abastecedora, CC.celula, CC.nome_cdo

SELECT *
FROM (
SELECT DISTINCT AA.[Código Survey]
FROM ASSOCIADOS..chave_totais AS TT
LEFT JOIN ASSOCIADOS..SERV_ASSOCIADOS AS AA
ON TT.[celula] = [Célula CEOS]
	AND TT.[estacao_abastecedora] = AA.[Sigla Est Abastecedora] 
	AND TT.[uf] = AA.[Sigla Unidade Federativa]
    AND TT.[nome_cdo] = AA.[CDOE I]
) AS XX
LEFT JOIN NETWIN_TOTAIS..ENDERECOS_TOTAIS AS T2
ON XX.[Código Survey] = T2.cod_survey
