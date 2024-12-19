function nb_ligne_fichier(file)
	local nb_ligne = 0
	for _ in io.lines(file) do
		nb_ligne = nb_ligne + 1
	end
	return nb_ligne
end

function lire(nom_fichier)
	local file = io.open(nom_fichier, "r")
	local new_graphe = {}

	if not file then
		print("fichier inexistant")
		return
	end


	local fichier = file:read("*a")
	file:close()

	local ligne = {}

	for line in string.gmatch(fichier, "[^\n]+") do
		local mot = {}
		for space in string.gmatch(line, "%S+") do
			table.insert(mot, space)
		end
		table.insert(ligne, mot)
	end

	local nb_ligne = #ligne

	for i = 0, nb_ligne/5 -1 do
		local e = {}
		for j = 0, 4 do
			table.insert(e, ligne[i*taille_Etat + j + 1])
		end
		local new_etat = Etat:new(e)
		new_graphe[new_etat.nom] = new_etat

	end

	return new_graphe
end

Etat = {
	nom = "",
	mouvement = {},
	lecture = {},
	ecriture = {},
	suivant = {}
}

taille_Etat = 5

function Etat:new(etat)
	local new_etat = {}
	new_etat.nom = etat[1][1]
	new_etat.lecture = etat[2]
	new_etat.mouvement = {}
	new_etat.ecriture = {}
	new_etat.suivant = {}

	for i = 1, #etat[2] do
		new_etat.ecriture[etat[2][i]] = etat[3][i]
		new_etat.mouvement[etat[2][i]] = etat[4][i]
		new_etat.suivant[etat[2][i]] = etat[5][i]
	end

	setmetatable(new_etat, self)
	self.__index = self

	return new_etat
end

function Etat:display()
	print("Nom de l'etat: " .. self.nom)
	-- for i = 1, 2 do
	-- 	print("Action "..i..":")
	-- 	print("\tLu: " .. self.lecture[i])
	-- 	print("\tEcrit: " .. self.ecriture[i])
	-- 	print("\tMouvement: " .. self.mouvement[i])
	-- 	print("\tSuivant: " .. self.suivant[i])
	-- end
end

function resoudre(phrase, graphe, nom_etat)
	local etat = graphe[nom_etat]
	local indice = 1
	
	local function replace_char(pos, str, r)
		if indice < 1 then
			return r .. str
		end
		if indice > #str then

			return str .. r 
		end
		if indice == 1 then
	    	return r .. string.sub(str, pos+1, #str)
		end
		if indice == #str then
			return string.sub(str, 1, pos-1) .. r
		end
		return string.sub(str, 1, pos-1) .. r .. string.sub(str, pos+1, #str)
	end

	local lettre = "0"
	local i = 0
	while true do
		if indice < 1 or indice > #phrase then
			lettre = "0"
		else
			lettre = string.sub(phrase, indice, indice)
		end
		local suivant = etat.suivant[lettre]

		if suivant == "arret" then
			break
		end

		phrase = replace_char(indice, phrase, etat.ecriture[lettre])
		local dir = etat.mouvement[lettre]
		
		if indice == 0 then 
			indice = 1
		end
		if dir == "d" then
			indice = indice + 1
		else
			indice = indice - 1
		end


		etat = graphe[suivant]
		
	end

	return phrase
end

local graphe = lire("doobler_un.txt")
local phrase = "111111"
local nom_etat = "e1"

local resultat = resoudre(phrase, graphe, nom_etat)

print(resultat)
