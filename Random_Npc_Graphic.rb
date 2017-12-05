=begin
###############################################################################
#                                                                             #
#                      Random NPC Graphic Script for VX Ace                   #
#                                                                             #
###############################################################################

Автор: Денис Кузнецов (http://vk.com/id8137201)
Версия: 1.3
Релиз от: 06.02.15

Данный скрипт привносит немного разнообразия в вашу игру. 

Инструкция:

В комментарии события напишите "NPC GRAPHIC - " без ковычек, потом название
чарсета, заканчивающееся .char, затем в скобках перечислите номера чаров, которые хотите 
использовать для эвента, также после этого вы можете указать 
направление эвента (куда он смотрит) - используйте после .char .dir(), где в
скобках укажите направление 2, 4, 6, 8
Например: NPC GRAPHIC - Actor2.char(123).dir(4) это приведет к тому, что каждый раз при 
переходе на карту, где стоит эвент его графика будет меняться случайным образом, 
то есть будет выбран чарсет Actor2 и случайный номер(либо 1, либо 2, либо 3) и у
него будет направление 4.
 
Учтите, что нумеровка чаров начинается с 0.
=end

class Game_Event < Game_Character
	
	alias denis_kyznetsov_rnd_npc_gm_event_setup_page_settings setup_page_settings
	def setup_page_settings
		denis_kyznetsov_rnd_npc_gm_event_setup_page_settings
		char_name = [] # массив названий чаров
		char_ind = [] # массив индексов чаров
		char_dir = [] # массив направлений чаров
		for command in list
			if command.code == 108 || command.code == 408
				if command.parameters[0] =~ /NPC[\w\s]*GRAPHIC[\s]*-[\s]*([а-яА-я\w\d\s\!\$\.\,\(\)]+).char/i
					char_name.push($1)
					char_ind.push($1) if command.parameters[0] =~ /.char\(([\d]+)\)/i
					char_dir.push($1) if command.parameters[0] =~ /.dir\(([\d]+)\)/i
				end
			end
		end
		name_size, ind_size = char_name.size, char_ind.size
		if name_size != 0 && ind_size != 0 && name_size == ind_size
			char_name_rand = rand(name_size) # выбираем случайный чар из массива имен
			index_array = char_ind[char_name_rand] # массив индексов, выбранного выше названия чара
			index_rand = rand(index_array.size) # случайный индекс из массива индексов, выбранного выше
			if char_dir[char_name_rand] # если у выбранного чара есть направления
				direction_array = char_dir[char_name_rand] # массив направлений для выбранного чара
				direction = direction_array[rand(direction_array.size)] # случайное направление из массива выше
			end
			@character_name = char_name[char_name_rand]
			@character_index = index_array[index_rand].to_i
			if !direction.nil? # если было указано направление чара
				@direction = direction.to_i
				@prelock_direction = @direction
			end
		end
	end
	
end # class Game_Event < Game_Character