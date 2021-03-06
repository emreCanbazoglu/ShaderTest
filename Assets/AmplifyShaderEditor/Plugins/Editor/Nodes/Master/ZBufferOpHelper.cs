using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace AmplifyShaderEditor
{
	public enum ZWriteMode
	{
		On,
		Off
	}

	public enum ZTestMode
	{
		Less,
		Greater,
		LEqual,
		GEqual,
		Equal,
		NotEqual,
		Always
	}

	[Serializable]
	class ZBufferOpHelper
	{
		public static readonly string DepthParametersStr = " Depth";
		public static readonly string ZWriteModeStr = "ZWrite Mode";
		public static readonly string ZTestModeStr = "ZTest Mode";
		public static readonly string OffsetStr = "Offset";
		public static readonly string OffsetFactorStr = "Factor";
		public static readonly string OffsetUnitsStr = "Units";
		private const string ExtraDepthPassStr = "Extra Depth Pass";
		private const string DepthZTestStr = "Depth ZTest";

		public static readonly string[] ZTestModeLabels =
		{
			"<Default>",
			"Less",
			"Greater",
			"Less or Equal",
			"Greater or Equal",
			"Equal",
			"Not Equal",
			"Always"
		};

		public static readonly string[] ZTestModeValues =
		{
			"<Default>",
			"Less",
			"Greater",
			"LEqual",
			"GEqual",
			"Equal",
			"NotEqual",
			"Always"
		};

		public static readonly string[] ZWriteModeValues =
		{
			"<Default>",
			"On",
			"Off"
		};

		public static readonly Dictionary<ZTestMode, int> ZTestModeDict = new Dictionary<ZTestMode, int>
		{
			{ZTestMode.Less,1 },
			{ZTestMode.Greater,2},
			{ZTestMode.LEqual,3},
			{ZTestMode.GEqual,4},
			{ZTestMode.Equal,5},
			{ZTestMode.NotEqual,6},
			{ZTestMode.Always,7}
		};

		public static readonly Dictionary<ZWriteMode, int> ZWriteModeDict = new Dictionary<ZWriteMode, int>
		{
			{ ZWriteMode.On,1},
			{ ZWriteMode.Off,2}
		};


		[SerializeField]
		private int m_zTestMode = 0;

		[SerializeField]
		private int m_zWriteMode = 0;

		[SerializeField]
		private float m_offsetFactor;

		[SerializeField]
		private float m_offsetUnits;

		[SerializeField]
		private bool m_offsetEnabled;

		[SerializeField]
		private bool m_extraDepthPass;

		[SerializeField]
		private int m_extrazTestMode = 0;

		[SerializeField]
		private StandardSurfaceOutputNode m_parentSurface;

		public string CreateDepthInfo( bool outlineZWrite, bool outlineZTest )
		{
			string result = string.Empty;
			if( m_zWriteMode != 0 )
			{
				MasterNode.AddRenderState( ref result, "ZWrite", ZWriteModeValues[ m_zWriteMode ] );
			} else if( outlineZWrite )
			{
				MasterNode.AddRenderState( ref result, "ZWrite", ZWriteModeValues[ 1 ] );
			}

			if( m_zTestMode != 0 )
			{
				MasterNode.AddRenderState( ref result, "ZTest", ZTestModeValues[ m_zTestMode ] );
			}
			else if( outlineZTest )
			{
				MasterNode.AddRenderState( ref result, "ZTest", ZTestModeValues[ 3 ] );
			}

			if( m_offsetEnabled )
			{
				MasterNode.AddRenderState( ref result, "Offset ", m_offsetFactor + " , " + m_offsetUnits );
			}

			return result;
		}

		public void Draw( UndoParentNode owner, GUIStyle toolbarstyle, bool customBlendAvailable )
		{
			Color cachedColor = GUI.color;
			GUI.color = new Color( cachedColor.r, cachedColor.g, cachedColor.b, 0.5f );
			EditorGUILayout.BeginHorizontal( toolbarstyle );
			GUI.color = cachedColor;
			EditorGUI.BeginChangeCheck();
			m_parentSurface.ContainerGraph.ParentWindow.ExpandedDepth = owner.GUILayoutToggle( m_parentSurface.ContainerGraph.ParentWindow.ExpandedDepth, DepthParametersStr, UIUtils.MenuItemToggleStyle );
			if( EditorGUI.EndChangeCheck() )
			{
				EditorPrefs.SetBool( "ExpandedDepth", m_parentSurface.ContainerGraph.ParentWindow.ExpandedDepth );
			}
			EditorGUILayout.EndHorizontal();

			if( m_parentSurface.ContainerGraph.ParentWindow.ExpandedDepth )
			{
				cachedColor = GUI.color;
				GUI.color = new Color( cachedColor.r, cachedColor.g, cachedColor.b, ( EditorGUIUtility.isProSkin ? 0.5f : 0.25f ) );
				EditorGUILayout.BeginVertical( UIUtils.MenuItemBackgroundStyle );
				GUI.color = cachedColor;

				EditorGUI.indentLevel++;
				if( !customBlendAvailable )
					EditorGUILayout.HelpBox( "Depth Writing is only available for Opaque or Custom blend modes", MessageType.Warning );

				EditorGUILayout.Separator();
				EditorGUI.BeginDisabledGroup( !customBlendAvailable );

				m_zWriteMode = owner.EditorGUILayoutPopup( ZWriteModeStr, m_zWriteMode, ZWriteModeValues );
				m_zTestMode = owner.EditorGUILayoutPopup( ZTestModeStr, m_zTestMode, ZTestModeLabels );
				m_offsetEnabled = owner.EditorGUILayoutToggle( OffsetStr, m_offsetEnabled );
				if( m_offsetEnabled )
				{
					EditorGUI.indentLevel++;
					m_offsetFactor = owner.EditorGUILayoutFloatField( OffsetFactorStr, m_offsetFactor );
					m_offsetUnits = owner.EditorGUILayoutFloatField( OffsetUnitsStr, m_offsetUnits );
					EditorGUI.indentLevel--;
				}

				m_extraDepthPass = owner.EditorGUILayoutToggle( ExtraDepthPassStr, m_extraDepthPass );
				if( m_extraDepthPass )
				{
					EditorGUI.indentLevel++;
					m_extrazTestMode = owner.EditorGUILayoutPopup( DepthZTestStr, m_extrazTestMode, ZTestModeLabels );
					EditorGUI.indentLevel--;
				}
				EditorGUILayout.Separator();
				EditorGUI.indentLevel--;
				EditorGUI.EndDisabledGroup();
				EditorGUILayout.EndVertical();
			}

			EditorGUI.EndDisabledGroup();
		}

		public void DrawExtraDepthPass( ref string shaderBody )
		{
			if( m_extraDepthPass )
			{
				shaderBody += "\t\tPass\n";
				shaderBody += "\t\t{\n";
				shaderBody += "\t\t\tColorMask 0\n";
				if( m_extrazTestMode != 0 )
					shaderBody += "\t\t\tZTest " + ZTestModeValues[ m_extrazTestMode ] + "\n";
				shaderBody += "\t\t\tZWrite On\n";
				shaderBody += "\t\t}\n\n";
			}
		}

		public void ReadFromString( ref uint index, ref string[] nodeParams )
		{
			if( UIUtils.CurrentShaderVersion() < 2502 )
			{
				string zWriteMode = nodeParams[ index++ ];
				m_zWriteMode = zWriteMode.Equals( "Off" ) ? 2 : 0;

				string zTestMode = nodeParams[ index++ ];
				for( int i = 0; i < ZTestModeValues.Length; i++ )
				{
					if( zTestMode.Equals( ZTestModeValues[ i ] ) )
					{
						m_zTestMode = i;
						break;
					}
				}
			}
			else
			{
				m_zWriteMode = Convert.ToInt32( nodeParams[ index++ ] );
				m_zTestMode = Convert.ToInt32( nodeParams[ index++ ] );
				m_offsetEnabled = Convert.ToBoolean( nodeParams[ index++ ] );
				m_offsetFactor = Convert.ToSingle( nodeParams[ index++ ] );
				m_offsetUnits = Convert.ToSingle( nodeParams[ index++ ] );

				if( UIUtils.CurrentShaderVersion() > 14202 )
				{
					m_extraDepthPass = Convert.ToBoolean( nodeParams[ index++ ] );
					m_extrazTestMode = Convert.ToInt32( nodeParams[ index++ ] );
				}
			}
		}

		public void WriteToString( ref string nodeInfo )
		{
			IOUtils.AddFieldValueToString( ref nodeInfo, m_zWriteMode );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_zTestMode );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_offsetEnabled );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_offsetFactor );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_offsetUnits );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_extraDepthPass );
			IOUtils.AddFieldValueToString( ref nodeInfo, m_extrazTestMode );
		}
		public bool IsActive { get { return m_zTestMode != 0 || m_zWriteMode != 0 || m_offsetEnabled; } }
		public StandardSurfaceOutputNode ParentSurface { get { return m_parentSurface; } set { m_parentSurface = value; } }
	}
}
