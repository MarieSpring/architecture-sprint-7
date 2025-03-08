| Роль| Права роли | Группы пользователей |
|-|-|-|
| cluster-administrator | get, list, watch, create, delete, update, patch. Полный доступ ко всем ключевым ресурсам кластера, включая управление секретами и другими чувствительными данными. Для администраторов, выполнение любых операций в кластере без ограничений  | administrators |
| cluster-readonly-user | get, list, watch. Для операции чтения. Только просмотр ресурсов кластера без возможности внесения изменений | viewers |
| cluster-configurator | get, list, watch, create, delete, update, patch. ДЛя просмотра и управления ресурсами кластера. Позоляет создавать, обновлять и удалять ресурсы | configurators |