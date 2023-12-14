SELECT DISTINCT *
FROM ASSOCIADOS..chave_totais AS TT
LEFT JOIN NETWIN_TOTAIS..ENDERECOS_TOTAIS AS T2
ON T2.[celula] LIKE TT.[celula] + ' %'
	AND TT.[estacao_abastecedora] = T2.[estacao_abastecedora] 
	AND TT.[uf] = T2.[uf]
    AND TRIM(TT.[nome_cdo]) = TRIM(T2.[nome_cdo])
