output "job_queue_arn" {
  value = aws_batch_job_queue.ecs_queue.arn
}

output "job_definition_arn" {
  value = aws_batch_job_definition.ecs_batch_job.arn
}