import credstash

def load_arguments(env):
    redshift_cluster_1_pass = credstash.getSecret(f'aws.infrastructure.redshift_cluster_1.master.pass', region='us-east-1')
    args = f"-var 'REDSHIFT_CLUSTER_1_PASS={redshift_cluster_1_pass}'"
    return args