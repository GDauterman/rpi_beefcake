import firebase_admin
from firebase_admin import firestore

def process_nut_doc(event, context):
    app = firebase_admin.initialize_app()
    client = firestore.client()

    total_calories = event["value"]["fields"]["total_calories"]["integerValue"]
    total_protein = event["value"]["fields"]["total_protein"]["integerValue"]
    total_fats = event["value"]["fields"]["total_fats"]["integerValue"]
    total_carbs = event["value"]["fields"]["total_carbs"]["integerValue"]

    timestamp = event["value"]["fields"]["time_logged"]["timestampValue"]
    event_date = timestamp[:10]


    resource_string = context.resource    
    resource_components = resource_string.split('/')

    graph_data_path = "users/"+resource_components[1]+"/raw_graph_points/"+event_date

    graph_doc_ref = client.document(graph_data_path)
    graph_doc = graph_doc_ref.get()
    if not graph_doc.exists:
        new_dict = {
            'sum_calories_y': total_calories,
            'sum_protein_y': total_protein,
            'sum_fats_y': total_fats,
            'sum_carbs_y': total_carbs,
            'sum_sleep_hours_y': -1,
            'avg_sleep_quality_y': -1,
            'sum_hydration_y': -1
        }
        graph_doc_ref.set(new_dict)

    else:
        graph_doc = graph_doc.to_dict()
        old_calories = graph_doc['sum_calories_y']
        old_protein = graph_doc['sum_protein_y']
        old_fats = graph_doc['sum_fats_y']
        old_carbs = graph_doc['sum_carbs']
        new_dict = {
            'sum_calories_y': total_calories + old_calories,
            'sum_protein_y': total_protein + old_protein,
            'sum_fats_y': total_fats + old_fats,
            'sum_carbs_y': total_carbs + old_carbs,
        }
        graph_doc_ref.update(new_dict)


