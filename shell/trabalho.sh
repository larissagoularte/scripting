#!/bin/bash

menuPrincipal(){
	opcaoPrincipal=$(dialog              	 \
		--stdout                         \
		--title 'Menu Principal'         \
		--menu 'Escoha uma opção: '      \
		0 0 0                            \
		1 'Compra'                       \
		2 'Venda'                        \
		3 'Visualizar dados' 	  	 \
		4 'Alterar dados'                \
		5 'Gestão de base de dados'      \
		6 'Relatórios'  	         \
		0 'Sair do programa')

	case $opcaoPrincipal in
		0) exit ;;
		1) buy ;;
		2) sell ;;
		3) seeData ;;
		4) alterData ;;
		5) database ;;
		6) reports ;;
	esac
}

countLines(){
	echo $(sed -n '$=' $1)
}

buy(){
	titulo=$(dialog --stdout --inputbox 'Titulo:' 0 0)
	preco=$(dialog --stdout --inputbox 'Preço:' 0 0)
	dataCompra=$(dialog --stdout --inputbox 'Data de compra:' 0 0)
	formato=$(dialog --stdout --inputbox 'Formato:' 0 0)

	echo $(($(countLines musicas.txt) + 1)):$titulo:$preco:$dataCompra:$formato >> musicas.txt

	echo $preco >> compras.txt

	dialog --msgbox 'Criado com sucesso!' 0 0
	menuPrincipal
}

# seeData(){
# 	for i in $(cat musicas.txt); do
# 		if [[ $i != *":SOLD:"* ]]; then
# 			echo $i
# 		fi
# 	done > .temp.txt.tmp

# 	dialog --textbox .temp.txt.tmp 0 0
# 	rm .temp.txt.tmp

# 	menuPrincipal
# }

seeData() {
	for i in $(cat musicas.txt); do
		if [[ $i != *":SOLD:"* ]]; then
			echo $i
		fi
	done > .temp.txt.tmp

	order=$(dialog --stdout --menu 'Ordenar por:' 0 0 0 1 'Id' 2 'Titulo' 3 'Preço' 4 'Formato')
	
	case $order in
		1) dialog --textbox .temp.txt.tmp 0 0 ;;
		2) orderData 1 ;;
		3) orderData 2 ;;
		4) orderData 3 ;;
	esac

	rm .temp.txt.tmp

	menuPrincipal
}

orderData(){
	# $1 is the option that the user choose
	# if the user choose 1 then order by the title
	# if the user choose 2 then order by the price
	# if the user choose 3 then order by the format
	case $1 in
		1) sort -t ':' -k 2 .temp.txt.tmp > .temp.txt.tmp2 ;;
		2) sort -t ':' -k 3 .temp.txt.tmp > .temp.txt.tmp2 ;;
		3) sort -t ':' -k 5 .temp.txt.tmp > .temp.txt.tmp2 ;;
	esac

	dialog --textbox .temp.txt.tmp2 0 0
	rm .temp.txt.tmp2
	
	
}

sell(){
	id=$(dialog --stdout --inputbox 'Id:' 0 0)
	preco=$(dialog --stdout --inputbox 'Preço:' 0 0)

	echo $preco >> vendas.txt

	awk -v id=$id -v preco=$preco 'BEGIN{FS=":"; OFS=":"} {if(NR==id) $0=$0":SOLD:"preco; print}' musicas.txt > musicas.txt.tmp
	mv musicas.txt.tmp musicas.txt

	dialog --msgbox 'Vendido com sucesso!' 0 0
	menuPrincipal
}

alterData(){
	id=$(dialog --stdout --inputbox 'Id:' 0 0)
	titulo=$(awk -v id=$id 'BEGIN{FS=":"} {if(NR==id) print $2}' musicas.txt)
	preco=$(awk -v id=$id 'BEGIN{FS=":"} {if(NR==id) print $3}' musicas.txt)
	dataCompra=$(awk -v id=$id 'BEGIN{FS=":"} {if(NR==id) print $4}' musicas.txt)
	formato=$(awk -v id=$id 'BEGIN{FS=":"} {if(NR==id) print $5}' musicas.txt)

	titulo=$(dialog --stdout --inputbox 'Titulo:' 0 0 $titulo)
	dataCompra=$(dialog --stdout --inputbox 'Data de compra:' 0 0 $dataCompra)
	formato=$(dialog --stdout --inputbox 'Formato:' 0 0 $formato)

	awk -v id=$id -v titulo=$titulo -v preco=$preco -v dataCompra=$dataCompra -v formato=$formato 'BEGIN{FS=":"; OFS=":"} {if(NR==id) $0=id":"titulo":"preco":"dataCompra":"formato; print}' musicas.txt > musicas.txt.tmp
	mv musicas.txt.tmp musicas.txt

	dialog --msgbox 'Alterado com sucesso!' 0 0
	menuPrincipal
}

database(){
	opcaoGestao=$(dialog              	 \
		--stdout                         \
		--title 'Gestão de base de dados'         \
		--menu 'Escoha uma opção: '      \
		0 0 0                            \
		1 'Criar backup'                       \
		2 'Restaurar backup'                        \
		3 'Apagar backup' 	  	 \
		0 'Voltar')

	case $opcaoGestao in
		0) menuPrincipal ;;
		1) createBackup ;;
		2) restoreBackup ;;
		3) deleteBackups ;;
	esac
}

createBackup(){
	cp compras.txt ./backup/compras.txt
	cp vendas.txt ./backup/vendas.txt
	cp musicas.txt ./backup/musicas.txt

	dialog --msgbox 'Backup criado com sucesso!' 0 0
	gestaoBaseDados
}

restoreBackup(){
	mkdir backup
	cp ./backup/compras.txt compras.txt
	cp ./backup/vendas.txt vendas.txt
	cp ./backup/musicas.txt musicas.txt

	dialog --msgbox 'Backup restaurado com sucesso!' 0 0
	gestaoBaseDados
}

deleteBackups(){
	rm backup/compras.txt
	rm backup/vendas.txt
	rm backup/musicas.txt

	dialog --msgbox 'Backup apagado com sucesso!' 0 0
	gestaoBaseDados
}

reports(){
	opcaoRelatorios=$(dialog              	 \
		--stdout                         \
		--title 'Relatórios'         \
		--menu 'Escoha uma opção: '      \
		0 0 0                            \
		1 'Relatório de compras'                       \
		2 'Relatório de vendas'                        \
		3 'Relatório de lucro' 	  	 \
		0 'Voltar')

	case $opcaoRelatorios in
		0) menuPrincipal ;;
		1) relatorioCompras ;;
		2) relatorioVendas ;;
		3) relatorioLucro ;;
	esac
}

relatorioCompras(){
	total=$(awk 'BEGIN{FS=":"; total=0} {total+=$1} END{print total}' compras.txt)

	numCompras=$(countLines compras.txt)

	media=$(awk 'BEGIN{FS=":"; total=0; count=0} {total+=$1; count++} END{print total/count}' compras.txt)

	echo "Total: $total
Número de compras: $numCompras
Média: $media" > .temp.txt.tmp

	dialog --textbox .temp.txt.tmp 0 0
	rm .temp.txt.tmp

	relatorios
}

relatorioVendas(){
	total=$(awk 'BEGIN{FS=":"; total=0} {total+=$1} END{print total}' vendas.txt)

	numVendas=$(countLines vendas.txt)

	media=$(awk 'BEGIN{FS=":"; total=0; count=0} {total+=$1; count++} END{print total/count}' vendas.txt)

	echo "Total: $total
Número de vendas: $numVendas
Média: $media" > .temp.txt.tmp

	dialog --textbox .temp.txt.tmp 0 0
	rm .temp.txt.tmp

	relatorios
}

relatorioLucro(){
	totalVendas=$(awk 'BEGIN{FS=":"; total=0} {total+=$1} END{print total}' vendas.txt)

	totalCompras=$(awk 'BEGIN{FS=":"; total=0} {total+=$1} END{print total}' compras.txt)

	lucro=$(echo "$totalVendas - $totalCompras" | bc)

	echo "Lucro: $lucro" > .temp.txt.tmp

	dialog --textbox .temp.txt.tmp 0 0
	rm .temp.txt.tmp

	relatorios
}

menuPrincipal
