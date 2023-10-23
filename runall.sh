#! /bin/sh
python parse_xml.py \
  \
    --xml_dir /xml_input \
    --out_dir /processed_data \
    --n_jobs 40

python preprocess.py \
  \
    --ecgmeta_path /processed_data/echonext_ecg_metadata.parquet \
    --out_dir /processed_data \
    --tabular_pipeline_path tabular_transformer.joblib \
    --waveform_params_path waveform_normalization_params.json \
    --n_jobs 20

python cradlenet/scripts/inference/ecg_tabular.py \
\
  --features_path /processed_data/waveforms.npy \
  --tabular_path /processed_data/tabular_features.npy \
\
  --legacy echonext \
  --batch_size 256 \
  --num_workers 2 \
  --write_outputs \
  --output_dir /results \
  --num_classes 12 \
  --len_tabular_feature_vector 7 \
  --filter_size 16 \
  --binary \
\
  --checkpoint 'echonext_multilabel_train_half1/best_checkpoint_27_validation_loss=-0.7351.pt'

python run_metrics.py \
\
  --ecgmeta_path /processed_data/ecg_metadata_final.parquet \
  --labels_path /xml_input/labels.csv \
  --prediction_path /results/prediction_loop/probs.npy \
  --output_dir /results