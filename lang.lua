Lang = {}

Lang.fr = {
    ['locker_title'] = 'Casiers',
    ['my_locker'] = 'Mon Casier',
    ['employees_lockers'] = 'Casiers des Employés',
    ['employees_list'] = 'Liste des Employés',
    ['employees_list_comment'] = 'Les employés seront ajoutés ici dynamiquement',
    ['no_access'] = 'Vous n\'avez pas accès à ce casier.',
    ['config_not_found'] = 'Configuration de casier introuvable.',
    ['insufficient_rights'] = 'Vous n\'avez pas les droits pour accéder à cette liste.',
    ['officer_not_found'] = 'Agent introuvable ou non en service.',
    ['officer_wrong_job'] = 'Agent introuvable ou n\'est pas dans le bon service.',
    ['no_employees_found'] = 'Aucun employé trouvé.',
    ['consulting_locker'] = 'Vous consultez un casier',
    ['personal_locker'] = 'Casier de',
    ['press_to_access'] = 'Appuyez sur ~INPUT_CONTEXT~ pour accéder aux ~b~%s~s~',
    ['online'] = 'En ligne',
    ['offline'] = 'Hors ligne',
    ['open'] = 'Ouvrir',
    ['rank'] = 'Rang',
}

Lang.en = {
    ['locker_title'] = 'Lockers',
    ['my_locker'] = 'My Locker',
    ['employees_lockers'] = 'Employees Lockers',
    ['employees_list'] = 'Employees List',
    ['employees_list_comment'] = 'Employees will be added here dynamically',
    ['no_access'] = 'You do not have access to this locker.',
    ['config_not_found'] = 'Locker configuration not found.',
    ['insufficient_rights'] = 'You do not have the rights to access this list.',
    ['officer_not_found'] = 'Officer not found or not on duty.',
    ['officer_wrong_job'] = 'Officer not found or not in the correct service.',
    ['no_employees_found'] = 'No employees found.',
    ['consulting_locker'] = 'You are consulting a locker',
    ['personal_locker'] = 'Locker of',
    ['press_to_access'] = 'Press ~INPUT_CONTEXT~ to access ~b~%s~s~',
    ['online'] = 'Online',
    ['offline'] = 'Offline',
    ['open'] = 'Open',
    ['rank'] = 'Rank',
}

function _U(str, ...)
    local lang = Config.Language or 'fr'
    local text = Lang[lang] and Lang[lang][str] or str
    
    if select('#', ...) > 0 then
        text = string.format(text, ...)
    end
    
    return text
end
