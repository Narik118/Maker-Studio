# TaskManagement

## Starting the server
To start the task management server:
  * Run `mix deps.get` to install all the dependencies 
  * Next run `mix phx.server`

server would be started on http://localhost:4000.

## User registration
 * send a request to `http://localhost:4000/api/v1/users` with 'email' and 'password' in the body.

## Get auth token
  * send a post request to `http://localhost:4000/api/v1/signin` with your email and password to get user id and Bearer token.

## How to use endpoints 
  * Add the Bearer token as auth header for all the below api requests

  * To create a new task - make a post request on `http://localhost:4000/api/v1/users/:user_id/tasks`. Returns `{"message": "Task successfully added", "task_id": taskid}` on success

  * To get all tasks of a user - make a get request on `http://localhost:4000/api/v1/users/:user_id/tasks`. Returns `{"message": " <number> tasks found for the user", "tasks": tasks}` or `{"message": "Only one task found for the user", "tasks": tasks}` on success

  * To get a specific task for a user - make a get request on `http://localhost:4000/api/v1/users/:user_id/tasks/:task_id`. Returns `{"message": task}` on success.

  * To update a specific task for a user - make a put request on `http://localhost:4000/api/v1/users/:user_id/tasks/:task_id`. Returns `{"message": "Task successfully updated", "updated_task": updated task}` on success

  * To delete a specific task for a user - make a delete request on `http://localhost:4000/api/v1/users/:user_id/tasks/:task_id`. Returns `{"messsage": "Task deleted successfully", "deleted_task": deleted_task}` on success.

## Errors 
 * `{"error": "Unauthorized or Invalid token"}` - This is returned when an unauthorised request is made.